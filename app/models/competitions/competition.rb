require 'fileutils'

# Results that derive their results from other Events. Se TYPES.
# Year-long: BAR, Ironman, WSBA Rider Rankings, Oregon Cup.
# Event-based: Cross Crusade, Mount Tabor Series.
#
# +point_schedule+: Array. How many points for each place?
# +source_events+: Which events count toward Competition? Not all Competitions use this relationship.
# Many dynamically choose their source events each time they calculate.
# +competition_event_memberships+: Relationship between source_events and competition.
#
# +calculate!+ is the main method
class Competition < Event
  include FileUtils
  
  TYPES = %w{
    AgeGradedBar
    Bar
    CascadeCrossOverall
    Cat4WomensRaceSeries
    CrossCrusadeOverall
    CrossCrusadeTeamCompetition
    Ironman
    OregonCup
    OregonJuniorCyclocrossSeries
    OverallBar
    TaborOverall
    TeamBar
  }

  attr_accessor :point_schedule

  after_create  :create_races
  # return true from before_save callback or Competition won't save
  before_save   { |competition| competition.notification = false; true }
  after_save    :expire_cache
  
  has_many :competition_event_memberships
  has_many :source_events, :through => :competition_event_memberships, :source => :event
  
  def self.find_for_year(year = RacingAssociation.current.year)
    self.find_by_date(Date.new(year, 1, 1))
  end
  
  def self.find_or_create_for_year(year = RacingAssociation.current.year)
    self.find_for_year(year) || self.create(:date => (Date.new(year, 1, 1)))
  end
  
  # Update results based on source event results.
  # (Calculate clashes with internal Rails method)
  # Destroys existing Competition for the year first.
  def Competition.calculate!(year = Date.today.year)
    benchmark(name, :level => :info) {
      transaction do
        year = year.to_i if year.is_a?(String)
        date = Date.new(year, 1, 1)
        competition = self.find_or_create_by_date(date)
        raise(ActiveRecord::ActiveRecordError, competition.errors.full_messages) unless competition.errors.empty?
        competition.destroy_races
        competition.create_races
        competition.create_children
        # Could bulk load all Event and Races at this point, but hardly seems to matter
        competition.calculate_members_only_places
        competition.calculate!
      end
    }
    # Don't return the entire populated instance!
    true
  end
  
  def default_date
    Time.new.beginning_of_year
  end

  def default_bar_points
    0
  end
  
  def default_ironman
    false
  end

  def default_name
    name
  end

  def friendly_name
    'Competition'
  end
  
  # Same as +date+. Should always be January 1st
  def start_date
    date
  end
  
  # Last day of year for +date+
  def end_date
    Date.new(date.year, 12, 31)
  end
  
  def date_range_long_s
    if multiple_days?
      "#{start_date.strftime('%a, %B %d')} to #{end_date.strftime('%a, %B %d, %Y')}"
    else
      start_date.strftime('%a, %B %d')
    end
  end
  
  def multiple_days?
    source_events.count > 1
  end

  # Assert start and end dates are first and last days of the year
  def valid_dates
    if !start_date or start_date.month != 1 or start_date.day != 1
      errors.add("start_date", "Start date must be January 1st")
    end
    if !end_date or end_date.month != 12 or end_date.day != 31
      errors.add("end_date", "End date must be December 31st")
    end
  end
  
  def name
    self[:name] ||= "#{self.date.year} #{friendly_name}"
  end
  
  def create_races
    category = Category.find_or_create_by_name(friendly_name)
    self.races.create(:category => category)
  end
  
  # Override in superclass for Competitions like OBRA OverallBAR
  def create_children
    true
  end

  # Some competitions are only open to RacingAssociation members, and non-members are dropped from the results.
  def calculate_members_only_places
    if place_members_only?
      # Uses batch_size, Rails 2.3 db cursor, to limit load on memory
      Race.find_each(:include => :event,
                :conditions => [ "events.type != ? and events.date between ? and ?", 
                                 self.class.name.demodulize, start_date, end_date ],
                :batch_size => 50
                ) do |r|
                  r.calculate_members_only_places!
                end
    end
  end
  
  # Rebuild results
  def calculate!
    races.each do |race|
      results = source_results_with_benchmark(race)
      create_competition_results_for(results, race)
      after_create_competition_results_for(race)
      race.place_results_by_points(break_ties?, ascending_points?)
    end
    
    # Explicity mark as updated to make it "dirty"
    self.updated_at_will_change!
    save!
  end
  
  def point_schedule
    @point_schedule = @point_schedule || []
  end
  
  # source_results must be in person, place ascending order
  def source_results(race)
    []
  end
  
  # Array of ids (integers)
  # +race+ category, +race+ category's siblings, and any competition categories
  def category_ids_for(race)
    ids = [ race.category_id ]
    ids = ids + race.category.descendants.map(&:id)
    ids.join(', ')
  end
  
  # If same rider places twice in same race, only highest result counts
  # TODO Replace ifs with methods
  def create_competition_results_for(results, race)
    competition_result = nil
    results.each_with_index do |source_result, index|
      logger.debug("#{self.class.name} scoring result: #{source_result.date} race: #{source_result.race.name} pl: #{source_result.place} mem pl: #{source_result.members_only_place if place_members_only?} #{source_result.last_name} #{source_result.team_name}") if logger.debug?

      person = source_result.person
      points = points_for(source_result)
      if points > 0.0 && (!members_only? || member?(person, source_result.date))
 
        if first_result_for_person(source_result, competition_result)
          # Intentionally not using results association create method. No need to hang on to all competition results.
          # In fact, this could cause serious memory issues with the Ironman
          competition_result = Result.create!(
             :person => person, 
             :team => (person ? person.team : nil),
             :race => race)
        end
 
        competition_result.scores.create_if_best_result_for_race(
          :source_result => source_result, 
          :competition_result => competition_result, 
          :points => points
        )
      end
      
      # Aggressive memory management. If competition has a race with many results, 
      # the results array can become a large, uneeded, structure
      results[index] = nil
      GC.start if index > 0 && index % 1000 == 0
    end
  end
  
  # By default, does nothing. Useful to apply rule like:
  # * Any results after the first four only get 50-point bonus
  # * Drop lowest-scoring result
  def after_create_competition_results_for(race)
  end
  
  def break_ties?
    true
  end
  
  def ascending_points?
    true
  end
  
  # Use the recorded place with all finishers? Or only place with just Assoication member finishers?
  def place_members_only?
    false
  end
  
  # Only members can score points?
  def members_only?
    true 
  end
  
  # Member this +date+ year?
  def member?(person_or_team, date)
    person_or_team && person_or_team.member_in_year?(date)
  end
  
  def first_result_for_person(source_result, competition_result)
    competition_result.nil? || source_result.person != competition_result.person
  end

  def first_result_for_team(source_result, competition_result)
    competition_result.nil? || source_result.team != competition_result.team
  end
  
  # Apply points from point_schedule, and split across team
  def points_for(source_result, team_size = nil)
    team_size = team_size || Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
    if place_members_only?
      points = point_schedule[source_result.members_only_place.to_i].to_f
    else
      points = point_schedule[source_result.place.to_i].to_f
    end
    if points
      points * points_factor(source_result) / team_size.to_f
    else
      0
    end
  end
  
  # multiplier from the CompetitionEventsMembership if it exists
  def points_factor(source_result)
    cem = source_result.event.competition_event_memberships.detect{|comp| comp.competition_id == self.id}
    # factor is one if membership is not found
    cem ? cem.points_factor : 1 
  end
  
  def requires_combined_results?
    false
  end

  # This method does nothing, and always returns true. Competitions don't participate in event notification.
  def disable_notification!
    true
  end

  # This method does nothing, and always returns true. Competitions don't participate in event notification.
  def enable_notification!
    true
  end

  # This method always returns false. Competitions don't participate in event notification.
  def notification_enabled?
    false
  end

  def expire_cache
    if ApplicationController.perform_caching
      ApplicationController.expire_cache
    end
  end

  def to_s
    "#<#{self.class} #{id} #{name} #{start_date} #{end_date}>"
  end
  
  protected
  
  def source_results_with_benchmark(race)
    results = []
    Competition.benchmark("#{self.class.name} source_results", :level => :debug) {
      results = source_results(race)
    }
    logger.debug("#{self.class.name} Found #{results.size} source results for '#{race.name}'") if logger.debug?
    results
  end
end
