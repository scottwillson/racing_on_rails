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
  # TODO Try using result dates, not event dates to find results
  include FileUtils
  include Concerns::Competition::Categories
  include Concerns::Competition::Dates
  include Concerns::Competition::Names
  include Concerns::Competition::Points
  
  TYPES = %w{
    AgeGradedBar
    Bar
    CascadeCrossOverall
    Cat4WomensRaceSeries
    CrossCrusadeCallups
    CrossCrusadeOverall
    CrossCrusadeTeamCompetition
    Ironman
    OregonCup
    OregonJuniorCyclocrossSeries
    OverallBar
    TaborOverall
    TeamBar
  }

  after_create  :create_races
  # return true from before_save callback or Competition won't save
  before_save   { |competition| competition.notification = false; true }
  after_save    :expire_cache
  
  has_many :competition_event_memberships
  has_many :source_events, :through => :competition_event_memberships, :source => :event
  
  def self.find_for_year(year = RacingAssociation.current.year)
    self.where("date between ? and ?", Time.zone.local(year).beginning_of_year.to_date, Time.zone.local(year).end_of_year.to_date).first
  end
  
  def self.find_for_year!(year = RacingAssociation.current.year)
    self.find_for_year(year) || raise(ActiveRecord::RecordNotFound)
  end
  
  def self.find_or_create_for_year(year = RacingAssociation.current.year)
    self.find_for_year(year) || self.create(:date => (Time.zone.local(year).beginning_of_year))
  end
  
  # Update results based on source event results.
  # (Calculate clashes with internal Rails method)
  def self.calculate!(year = Time.zone.today.year)
    benchmark(name, :level => :info) {
      transaction do
        year = year.to_i if year.is_a?(String)
        competition = self.find_or_create_for_year(year)
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
  
  def default_ironman
    false
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
                :conditions => [ "events.type != ? and events.date between ? and ? and (events.updated_at > ? || races.updated_at > ?)", 
                                 self.class.name.demodulize, start_date, end_date, 1.week.ago, 1.week.ago ]
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
    
    after_calculate
    save!
  end
  
  # Callback
  def after_calculate
    self.updated_at = Time.zone.now
  end
  
  # source_results must be in person, place ascending order
  def source_results(race)
    []
  end
  
  # If same rider places twice in same race, only highest result counts
  # TODO Replace ifs with methods
  def create_competition_results_for(results, race)
    competition_result = nil
    person = nil

    results.each_with_index do |source_result, index|
      logger.debug("#{self.class.name} scoring result: #{source_result.date} race: #{source_result.race_name} pl: #{source_result.place} mem pl: #{source_result.members_only_place if place_members_only?} #{source_result.last_name} #{source_result.team_name}") if logger.debug?

      points = points_for(source_result)

      if person.nil? || source_result.try(:person_id) != person.id
        person = Person.includes(:names, :team => :names).where(:id => source_result.person_id).first
      end
      
      if points > 0.0 && (!members_only? || member?(person, source_result.date))
        if first_result_for_person?(source_result, competition_result)
          # Intentionally not using results association create method. No need to hang on to all competition results.
          # In fact, this could cause serious memory issues with the Ironman
          competition_result = Result.create!(
             :person => person, 
             :team => person.try(:team),
             :event => self,
             :race => race)
        end
 
        competition_result.scores.create_if_best_result_for_race(
          :source_result => source_result, 
          :competition_result_id => competition_result.id, 
          :points => points
        )
      end
    end
  end
  
  # By default, does nothing. Useful to apply rule like:
  # * Any results after the first four only get 50-point bonus
  # * Drop lowest-scoring result
  def after_create_competition_results_for(race)
    if maximum_events
      race.results.each do |result|
        # Don't bother sorting scores unless we need to drop some
        if result.scores.size > maximum_events
          result.scores.sort! { |x, y| y.points <=> x.points }
          lowest_scores = result.scores[maximum_events, 2]
          lowest_scores.each do |lowest_score|
            result.scores.destroy(lowest_score)
          end
          # Rails destroys Score in database, but doesn't update the current association
          result.scores(true)
        end

        if preliminary?(result)
          result.preliminary = true       
        end    
      end
    end
  end
  
  def maximum_events
    nil
  end
  
  def break_ties?
    true
  end
  
  def first_result_for_person?(source_result, competition_result)
    competition_result.nil? || source_result.person_id != competition_result.person_id
  end

  def first_result_for_team?(source_result, competition_result)
    competition_result.nil? || source_result.team_id != competition_result.team_id
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
