module Competitions
  module Calculations
    # Override superclass methods so some Competitions can use Calculator
    module CalculatorAdapter
      # Rebuild results
      def calculate!
        before_calculate

        races.each do |race|
          results = source_results_with_benchmark(race)
          results = add_field_size(results)
          results = map_team_member_to_boolean(results)
          
          calculated_results = Calculator.calculate(
            results,
            break_ties: break_ties?,
            dnf: dnf?,
            field_size_bonus: field_size_bonus?,
            members_only: members_only?,
            maximum_events: maximum_events(race),
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

      # Calculate field size if needed. It's not stored in the DB, and can't be calculated
      # from source results.
      def add_field_size(results)
        if field_size_bonus?
          field_sizes = ::Result.group(:race_id).count
          results.each do |result|
            result["field_size"] = field_sizes[result["race_id"]]
          end
        else
          results
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
        obselete_races = races.select { |race| !race.name.in?(category_names) }
        if obselete_races.any?
          race_ids = obselete_races.map(&:id)
          Competitions::Score.delete_all("competition_result_id in (select id from results where race_id in (#{race_ids.join(',')}))")
          Result.where("race_id in (?)", race_ids).delete_all
        end
        obselete_races.each { |race| races.delete(race) }
      end
      
      def partition_results(calculated_results, race)
        Rails.logger.debug("CalculatorAdapter#partition_results")
        participant_ids            = race.results.map(&participant_id_attribute)
        calculated_participant_ids = calculated_results.map(&:participant_id)

        new_participant_ids      = calculated_participant_ids - participant_ids
        existing_participant_ids = calculated_participant_ids & participant_ids
        old_participant_ids      = participant_ids - calculated_participant_ids
    
        [
          calculated_results.select { |r| r.participant_id.in? new_participant_ids },
          calculated_results.select { |r| r.participant_id.in? existing_participant_ids },
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
        results.each do |result|
          competition_result = ::Result.create!(
            place: result.place,
            person_id: person_id_for_competition_result(result),
            team_id: team_id_for_competition_result(result, results),
            event: self,
            race: race,
            competition_result: true,
            team_competition_result: team?,
            points: result.points
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
        
        @team_ids_by_person_id_hash = nil

        existing_results = race.results.where(participant_id_attribute => results.map(&:participant_id)).includes(:scores)
        results.each do |result|
          existing_result = existing_results.detect { |r| r[participant_id_attribute] == result.participant_id }
      
          # to_s important. Otherwise, a change from 3 to "3" triggers a DB update.
          existing_result.place   = result.place.to_s
          existing_result.points  = result.points
          if !team?
            existing_result.team_id = team_ids_by_person_id_hash(results)[result.participant_id]
          end

          # TODO Why do we need explicit dirty check?
          if existing_result.place_changed? || existing_result.team_id_changed? || existing_result.points_changed?
            existing_result.save!
          end

          existing_scores = existing_result.scores.map { |s| [ s.source_result_id, s.points.to_f ] }
          new_scores = result.scores.map { |s| [ s.source_result_id, s.points.to_f ] }
      
          scores_to_create = new_scores - existing_scores
          scores_to_delete = existing_scores - new_scores
      
          scores_to_create.each do |score|
            create_score existing_result, score.first, score.last
          end

          if scores_to_delete.present?
            Score.where(competition_result_id: existing_result.id).where(source_result_id: scores_to_delete.map(&:first)).delete_all
          end
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
      def team_ids_by_person_id_hash(results)
        if @team_ids_by_person_id_hash.nil?
          @team_ids_by_person_id_hash = Hash.new
          ::Person.select("id, team_id").where("id in (?)", results.map(&:participant_id).uniq).map do |person|
            @team_ids_by_person_id_hash[person.id] = person.team_id
          end
        end
        @team_ids_by_person_id_hash
      end

      # This is always the 'best' result
      def create_score(competition_result, source_result_id, points)
        ::Competitions::Score.create!(
          source_result_id: source_result_id,
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

      def team_id_for_competition_result(result, results)
        if team?
          result.participant_id
        else
          team_ids_by_person_id_hash(results)[result.participant_id]
        end
      end
    end
  end
end
