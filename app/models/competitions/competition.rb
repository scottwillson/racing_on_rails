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

    def add_source_events
      parent.children.each do |source_event|
        source_events << source_event
      end
    end

    def create_races
      race_category_names.each do |name|
        category = Category.where(name: name).first
        if category.nil?
          category = Category.create!(raw_name: name)
        end
        if !races.where(category: category).exists?
          if team?
            races.create! category: category, result_columns: %W{ place team_name points }
          else
            races.create! category: category
          end
        end
      end
    end

    # Override in superclass for Competitions like OBRA OverallBAR
    def create_children
      true
    end

    # Rebuild results
    def calculate!
      before_calculate

      races_in_upgrade_order.each do |race|
        results = source_results(race)
        results = add_upgrade_results(results, race)
        results = after_source_results(results, race)
        results = delete_non_calculation_attributes(results)
        results = add_field_size(results)
        results = map_team_member_to_boolean(results)

        calculated_results = Calculations::Calculator.calculate(
          results,
          break_ties: break_ties?,
          completed_events: completed_events,
          dnf_points: dnf_points,
          double_points_for_last_event: double_points_for_last_event?,
          end_date: end_date,
          field_size_bonus: field_size_bonus?,
          maximum_events: maximum_events(race),
          maximum_upgrade_points: maximum_upgrade_points,
          members_only: members_only?,
          minimum_events: minimum_events,
          missing_result_penalty: missing_result_penalty,
          most_points_win: most_points_win?,
          place_bonus: place_bonus,
          points_schedule_from_field_size: points_schedule_from_field_size?,
          point_schedule: point_schedule,
          results_per_event: results_per_event,
          results_per_race: results_per_race,
          source_event_ids: source_event_ids(race),
          team: team?,
          use_source_result_points: use_source_result_points?
        )

        new_results, existing_results, obselete_results = partition_results(calculated_results, race)
        Rails.logger.debug "Calculator new_results:      #{new_results.size}"
        Rails.logger.debug "Calculator existing_results: #{existing_results.size}"
        Rails.logger.debug "Calculator obselete_results: #{obselete_results.size}"
        create_competition_results_for new_results, race
        update_competition_results_for existing_results, race
        delete_competition_results_for obselete_results, race
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

    def races_in_upgrade_order
      if upgrades.any?
        upgrade_categories = upgrades.values.map { |categories| Array.wrap(categories) }.flatten
        categories_in_upgrade_order = upgrade_categories + (races.map(&:name) - upgrade_categories)
        categories_in_upgrade_order.map { |name| races.detect { |race| race.name == name }}.compact
      else
        races
      end
    end

    def source_results(race)
      Competition.benchmark("#{self.class.name} source_results", level: :debug) do
        Result.connection.select_all source_results_query(race)
      end
    end

    def source_results_query(race)
      query = Result.
        select(
          "distinct results.id as id",
          "1 as multiplier",
          "age",
          "categories.ability as category_ability",
          "categories.ages_begin as category_ages_begin",
          "categories.ages_end as category_ages_end",
          "categories.gender as category_gender",
          "events.bar_points as event_bar_points",
          "events.date",
          "events.discipline",
          "events.type",
          "gender",
          "member_from",
          "member_to",
          "parents_events.bar_points as parent_bar_points",
          "parents_events_2.bar_points as parent_parent_bar_points",
          "people.gender as person_gender",
          "people.name as person_name",
          "races.bar_points as race_bar_points",
          "results.#{participant_id_attribute} as participant_id",
          "results.event_id",
          "place",
          "results.points",
          "results.race_id",
          "results.race_name as category_name",
          "results.year",
          "team_member",
          "team_name"
        ).
        joins(:race, :event, :person).
        joins("left outer join events parents_events on parents_events.id = events.parent_id").
        joins("left outer join events parents_events_2 on parents_events_2.id = parents_events.parent_id").
        joins("left outer join categories on categories.id = races.category_id").
        where("results.year = ?", year)

      if source_event_types.include?(Event)
        query = query.where("(events.type in (?) or events.type is NULL)", source_event_types)
      else
        query = query.where("events.type in (?)", source_event_types)
      end

      query
    end

    def after_source_results(results, race)
      results
    end

    # TODO just do this in source_results with join
    def add_upgrade_results(results, race)
      if race.name.in?(upgrades.keys)
        upgrade_categories = Array.wrap(upgrades[race.name])
        upgrade_races = races.select { |r| r.name.in?(upgrade_categories) }
        results.to_a + Result.connection.select_all(Result.
          select(
            "distinct results.id as id",
            "1 as multiplier",
            "events.bar_points as event_bar_points",
            "events.date",
            "events.type",
            "member_from",
            "member_to",
            "parents_events.bar_points as parent_bar_points",
            "parents_events_2.bar_points as parent_parent_bar_points",
            "place",
            "races.bar_points as race_bar_points",
            "results.#{participant_id_attribute} as participant_id",
            "results.event_id",
            "results.points",
            "results.race_id",
            "results.race_name as category_name",
            "results.year",
            "team_member",
            "team_name",
            "true as upgrade"
          ).
          joins(:race, :event, :person).
          joins("left outer join events parents_events on parents_events.id = events.parent_id").
          joins("left outer join events parents_events_2 on parents_events_2.id = parents_events.parent_id").
          where("results.race_id" => upgrade_races).
          # Only include upgrade results for people with category results
          where(
            "results.#{participant_id_attribute}" =>
            results.select { |r| r["event_bar_points"] != 0 }.map { |r| r["participant_id"] }.uniq
          )
        ).to_a
      else
        results
      end
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

    def delete_non_calculation_attributes(results)
      non_calculation_attributes = %w{
          age
          category_ability
          category_ages_begin
          category_ages_end
          category_gender
          discipline
          event_bar_points
          gender
          parent_bar_points
          parent_parent_bar_points
          person_gender
          person_name
          race_bar_points
      }
      results.map do |result|
        result.except(*non_calculation_attributes)
      end
    end

    # Calculate field size. It's not stored in the DB, and can't be calculated
    # from source results. Eventually, *should* load all results and calculate
    # in Calculator.
    def add_field_size(results)
      results.each do |result|
        result["field_size"] = field_sizes[result["race_id"]]
      end
    end

    def field_sizes
      @field_sizes ||= ::Result.group(:race_id).count
    end

    def set_team_size_to_one(results)
      results.each { |r| r["team_size"] = 1 }
    end

    def completed_events
      if source_events?
        source_events.select(&:any_results?).size
      end
    end

    def map_team_member_to_boolean(results)
      if team?
        results.each do |result|
          if result["team_member"] == 1
            result["team_member"] = true
          else
            result["team_member"] = false
          end
        end
      else
        results
      end
    end

    # Only delete obselete races
    def delete_races
      obselete_races = races.select { |race| !race.name.in?(race_category_names) }
      if obselete_races.any?
        race_ids = obselete_races.map(&:id)
        Competitions::Score.delete_all("competition_result_id in (select id from results where race_id in (#{race_ids.join(',')}))")
        Result.where("race_id in (?)", race_ids).delete_all
      end
      obselete_races.each { |race| races.delete(race) }
    end

    def partition_results(calculated_results, race)
      participant_ids            = race.results.map(&participant_id_attribute)
      calculated_participant_ids = calculated_results.map(&:participant_id)

      new_participant_ids      = calculated_participant_ids - participant_ids
      existing_participant_ids = calculated_participant_ids & participant_ids
      old_participant_ids      = participant_ids            - calculated_participant_ids

      [
        calculated_results.select { |r| r.participant_id.in?            new_participant_ids },
        calculated_results.select { |r| r.participant_id.in?            existing_participant_ids },
        race.results.select       { |r| r[participant_id_attribute].in? old_participant_ids }
      ]
    end

    def participant_id_attribute
      if team?
        :team_id
      else
        :person_id
      end
    end

    def person_id_for_competition_result(result)
      if team?
        nil
      else
        result.participant_id
      end
    end

    def create_competition_results_for(results, race)
      Rails.logger.debug "create_competition_results_for #{race.name}"

      team_ids = team_ids_by_participant_id_hash(results)

      results.each do |result|
        competition_result = ::Result.create!(
          competition_result: true,
          event: self,
          person_id: person_id_for_competition_result(result),
          place: result.place,
          points: result.points,
          preliminary: result.preliminary,
          race: race,
          team_competition_result: team?,
          team_id: team_ids[result.participant_id]
        )

        result.scores.each do |score|
          create_score competition_result, score.source_result_id, score.points, score.notes
        end
      end

      true
    end

    def update_competition_results_for(results, race)
      Rails.logger.debug "update_competition_results_for #{race.name}"
      return true if results.empty?

      team_ids = team_ids_by_participant_id_hash(results)
      existing_results = race.results.where(participant_id_attribute => results.map(&:participant_id)).includes(:scores)

      results.each do |result|
        update_competition_result_for result, existing_results, team_ids
      end
    end

    def update_competition_result_for(result, existing_results, team_ids)
      existing_result = existing_results.detect { |r| r[participant_id_attribute] == result.participant_id }

      # Ensure true or false, not nil
      existing_result.preliminary   = result.preliminary ? true : false
      # to_s important. Otherwise, a change from 3 to "3" triggers a DB update.
      existing_result.place         = result.place.to_s
      existing_result.points        = result.points
      existing_result.team_id       = team_ids[result.participant_id]

      # TODO Why do we need explicit dirty check?
      if existing_result.place_changed? || existing_result.team_id_changed? || existing_result.points_changed? || existing_result.preliminary_changed?
        existing_result.save!
      end

      update_scores_for result, existing_result
    end

    def update_scores_for(result, existing_result)
      existing_scores = existing_result.scores.map { |s| [ s.source_result_id, s.points.to_f, s.notes ] }
      new_scores = result.scores.map { |s| [ s.source_result_id || existing_result.id, s.points.to_f, s.notes ] }

      scores_to_create = new_scores - existing_scores
      scores_to_delete = existing_scores - new_scores

      # Delete first because new scores might have same key
      if scores_to_delete.present?
        Score.where(competition_result_id: existing_result.id).where(source_result_id: scores_to_delete.map(&:first)).delete_all
      end

      scores_to_create.each do |score|
        create_score existing_result, score.first, score.second, score.last
      end
    end

    def delete_competition_results_for(results, race)
      Rails.logger.debug "delete_competition_results_for #{race.name}"
      if results.present?
        Score.where(competition_result_id: results).delete_all
        Result.where(id: results).delete_all
      end
    end

    # Competition results could know they need to lookup their team
    # Can move to Result?
    def team_ids_by_participant_id_hash(results)
      team_ids_by_participant_id_hash = Hash.new
      results.map(&:participant_id).uniq.each do |participant_id|
        team_ids_by_participant_id_hash[participant_id] = participant_id
      end
      if team?
      else
        ::Person.select("id, team_id").where("id in (?)", results.map(&:participant_id).uniq).map do |person|
          team_ids_by_participant_id_hash[person.id] = person.team_id
        end
      end

      team_ids_by_participant_id_hash
    end

    # This is always the 'best' result
    def create_score(competition_result, source_result_id, points, notes)
      ::Competitions::Score.create!(
        source_result_id: source_result_id || competition_result.id,
        competition_result_id: competition_result.id,
        notes: notes,
        points: points
      )
    end

    def source_event_types
      [ SingleDayEvent, Event ]
    end

    def source_event_ids(race)
      if source_events?
        source_events.map(&:id)
      end
    end

    def minimum_events
      nil
    end

    def missing_result_penalty
      nil
    end

    def maximum_events(race)
      nil
    end

    def maximum_upgrade_points
      Competition::UNLIMITED
    end

    def place_bonus
      nil
    end

    def points_schedule_from_field_size?
      false
    end

    def break_ties?
      true
    end

    def dnf_points
      0
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

    # Team-based competition? False (default) implies it is person-based.
    def team?
      false
    end

    def default_ironman
      false
    end

    def upgrades
      {}
    end

    def expire_cache
      ApplicationController.expire_cache
    end
  end
end
