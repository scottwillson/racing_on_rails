module Competitions
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
    include Competitions::Categories
    include Competitions::Dates
    include Competitions::Naming
    include Competitions::Points

    TYPES = %w{
      Competitions::AgeGradedBar
      Competitions::Bar
      Competitions::Cat4WomensRaceSeries
      Competitions::CrossCrusadeCallups
      Competitions::CrossCrusadeOverall
      Competitions::CrossCrusadeTeamCompetition
      Competitions::Ironman
      Competitions::OregonTTCup
      Competitions::OregonCup
      Competitions::OregonJuniorCyclocrossSeries
      Competitions::OregonWomensPrestigeSeries
      Competitions::OregonWomensPrestigeTeamSeries
      Competitions::OverallBar
      Competitions::TaborOverall
      Competitions::TeamBar
    }

    UNLIMITED = Float::INFINITY

    after_create  :create_races
    after_save    :expire_cache

    has_many :competition_event_memberships
    has_many :source_events,
             through: :competition_event_memberships,
             source: :event,
             class_name: "::Event"

    def self.find_for_year(year = RacingAssociation.current.year)
      self.where("date between ? and ?", Time.zone.local(year).beginning_of_year.to_date, Time.zone.local(year).end_of_year.to_date).first
    end

    def self.find_for_year!(year = RacingAssociation.current.year)
      self.find_for_year(year) || raise(ActiveRecord::RecordNotFound)
    end

    def self.find_or_create_for_year(year = RacingAssociation.current.year)
      self.find_for_year(year) || self.create(date: (Time.zone.local(year).beginning_of_year))
    end

    # Update results based on source event results.
    # (Calculate clashes with internal Rails method)
    def self.calculate!(year = Time.zone.today.year)
      ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
        transaction do
          year = year.to_i if year.is_a?(String)
          competition = self.find_or_create_for_year(year)
          competition.set_date
          raise(ActiveRecord::ActiveRecordError, competition.errors.full_messages) unless competition.errors.empty?
          competition.delete_races
          competition.create_races
          competition.create_children
          # Could bulk load all Event and Races at this point, but hardly seems to matter
          competition.calculate_members_only_places
          competition.calculate!
        end
      end
      # Don't return the entire populated instance!
      true
    end

    def default_ironman
      false
    end

    def delete_races
      if races.present?
        race_ids = races.map(&:id)
        Competitions::Score.delete_all("competition_result_id in (select id from results where race_id in (#{race_ids.join(',')}))")
        Result.where("race_id in (?)", race_ids).delete_all
      end
      races.clear
    end

    def create_races
      category_names.each do |name|
        category = Category.where(name: name).first
        if category.nil?
          category = Category.create!(raw_name: name)
        end
        self.races.create(category: category)
      end
    end

    # Override in superclass for Competitions like OBRA OverallBAR
    def create_children
      true
    end

    # Some competitions are only open to RacingAssociation members, and non-members are dropped from the results.
    def calculate_members_only_places
      if place_members_only?
        Race.
          includes(:event).
          where("events.type != ?", self.class.name.demodulize).
          year(year).
          where("events.updated_at > ? || races.updated_at > ?", 1.week.ago, 1.week.ago).
          references(:events).
          find_each do |r|
            r.calculate_members_only_places!
          end
      end
    end

    # Rebuild results
    def calculate!
      before_calculate

      races.each do |race|
        results = source_results_with_benchmark(race)
        create_competition_results_for results, race
        after_create_competition_results_for race
        race.results.each(&:update_points!)
        race.place_results_by_points break_ties?, ascending_points?
      end

      after_calculate
      save!
    end

    # Callback
    def before_calculate
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

        if person.nil? || source_result.person_id != person.id
          person = source_result.person
        end

        # Competitions that use competition results (e.g., Overall BAR uses discipline BAR)
        # assume that first competition checked membership requirements
        if person && points > 0.0 && (!members_only? || source_result.competition_result? || person.member_in_year?(source_result.date))
          if first_result_for_person?(source_result, competition_result)
            # Intentionally not using results association create method. No need to hang on to all competition results.
            # In fact, this could cause serious memory issues with the Ironman
            competition_result = Result.create!(
               person: person,
               team: person.team,
               event: self,
               race: race,
               competition_result: true)
          end

          create_score competition_result, source_result, points
        end
      end
    end

    def create_score(competition_result, source_result, points)
      competition_result.scores.create_if_best_result_for_race(
        source_result: source_result,
        competition_result_id: competition_result.id,
        points: points
      )
    end

    # By default, does nothing. Useful to apply rule like:
    # * Any results after the first four only get 50-point bonus
    # * Drop lowest-scoring result
    def after_create_competition_results_for(race)
      _maximum_events = maximum_events(race)
      if _maximum_events
        race.results.each do |result|
          # Don't bother sorting scores unless we need to drop some
          if result.scores.size > _maximum_events
            scores = result.scores.sort { |x, y| y.points <=> x.points }
            lowest_scores = scores[_maximum_events, 2]
            lowest_scores.each(&:destroy)
            # Rails destroys Score in database, but doesn't update the current association
            result.scores(true)
          end

          if preliminary?(result)
            result.update_column :preliminary, true
          end
        end
      end
    end

    # Only consider results from source_events. Default to false: use all events in year.
    def source_events?
      false
    end

    def source_event_ids(race)
      if source_events?
        source_events.map(&:id)
      end
    end

    def maximum_events(race)
      nil
    end

    def preliminary?(result)
      false
    end

    def first_result_for_person?(source_result, competition_result)
      competition_result.nil? || source_result.person_id != competition_result.person_id
    end

    def first_result_for_team?(source_result, competition_result)
      competition_result.nil? || source_result.team_id != competition_result.team_id
    end

    def break_ties?
      true
    end

    def dnf?
      false
    end

    def results_per_event
      Competition::UNLIMITED
    end

    def results_per_race
      1
    end

    def use_source_result_points?
      false
    end

    # Team-based competition? False (default) implies it is person-based?
    def team?
      false
    end

    def expire_cache
      ApplicationController.expire_cache
    end

    def to_s
      "#<#{self.class} #{id} #{name} #{start_date} #{end_date}>"
    end

    protected

    def source_results_with_benchmark(race)
      results = []
      Competition.benchmark("#{self.class.name} source_results", level: :debug) {
        results = source_results(race)
      }
      if logger.debug?
        if results.respond_to?(:rows)
          logger.debug("#{self.class.name} Found #{results.rows.size} source results for '#{race.name}'")
        else
          logger.debug("#{self.class.name} Found #{results.size} source results for '#{race.name}'")
        end
      end
      results
    end
  end
end
