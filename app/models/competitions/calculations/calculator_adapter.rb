module Competitions
  module Calculations
    # Override superclass methods so some Competitions can use Calculator
    module CalculatorAdapter
      # Rebuild results
      def calculate!
        before_calculate

        races_in_upgrade_order.each do |race|
          results = source_results_with_benchmark(race)
          results = add_upgrade_results(results, race)
          results = after_source_results(results)
          results = delete_bar_points(results)
          results = add_field_size(results)
          results = map_team_member_to_boolean(results)

          calculated_results = Calculator.calculate(
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

      def source_results(race)
        Result.connection.select_all source_results_query(race)
      end

      def source_results_query(race)
        query = Result.
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
          where("results.year = ?", year)

        if source_event_types.include?(Event)
          query = query.where("(events.type in (?) or events.type is NULL)", source_event_types)
        else
          query = query.where("events.type in (?)", source_event_types)
        end

        query
      end

      def source_event_types
        [ SingleDayEvent, Event ]
      end

      def after_source_results(results)
        results
      end

      # TODO just do this in source_results with join
      def add_upgrade_results(results, race)
        if race.name.in?(upgrades.keys)
          upgrade_race = races.detect { |r| r.name == upgrades[race.name] }
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
              "races.bar_points as race_bar_points",
              "results.#{participant_id_attribute} as participant_id",
              "results.event_id",
              "place",
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
            where("results.race_id = ?", upgrade_race).
            # Only include upgrade results for people with category results
            where("results.#{participant_id_attribute} in (?)", results.map { |r| r["participant_id"] }.uniq )
          ).to_a
        else
          results
        end
      end

      # TODO remove?
      def delete_bar_points(results)
        results.each do |result|
          %w{ race_bar_points event_bar_points parent_bar_points parent_parent_bar_points }.each do |a|
            result.delete a
          end
        end
        results
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
        Rails.logger.debug "CalculatorAdapter#partition_results"
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

      # Similar to superclass's method, except this method only saves results to the database. Superclass applies rules
      # and scoring. It also decorates the results with any display data (often denormalized)
      # like people's names, teams, and points.
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
            create_score competition_result, score.source_result_id, score.points
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
        existing_scores = existing_result.scores.map { |s| [ s.source_result_id, s.points.to_f ] }
        new_scores = result.scores.map { |s| [ s.source_result_id || existing_result.id, s.points.to_f ] }

        scores_to_create = new_scores - existing_scores
        scores_to_delete = existing_scores - new_scores

        # Delete first because new scores might have same key
        if scores_to_delete.present?
          Score.where(competition_result_id: existing_result.id).where(source_result_id: scores_to_delete.map(&:first)).delete_all
        end

        scores_to_create.each do |score|
          create_score existing_result, score.first, score.last
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
      def create_score(competition_result, source_result_id, points)
        ::Competitions::Score.create!(
          source_result_id: source_result_id || competition_result.id,
          competition_result_id: competition_result.id,
          points: points
        )
      end

      def person_id_for_competition_result(result)
        if team?
          nil
        else
          result.participant_id
        end
      end
    end
  end
end
