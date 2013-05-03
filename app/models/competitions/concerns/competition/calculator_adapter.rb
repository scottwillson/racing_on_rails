module Concerns
  module Competition
    # Override superclass methods so some Competitions can use Competitions::Calculator
    module CalculatorAdapter
      # Rebuild results
      def calculate!
        races.each do |race|
          results = source_results_with_benchmark(race)
          results = add_field_size(results)
          results = map_team_member_to_boolean(results)

          calculated_results = Competitions::Calculator.calculate(
            results, 
            break_ties: break_ties?,
            dnf: dnf?,
            field_size_bonus: field_size_bonus?,
            point_schedule: point_schedule, 
            results_per_event: results_per_event,
            results_per_race: results_per_race,
            team: team?,
            use_source_result_points: use_source_result_points?
          )

          create_competition_results_for(calculated_results, race)
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

      # Similar to superclass's method, except this method only saves results to the database. Superclass applies rules 
      # and scoring. It also decorates the results with any display data (often denormalized)
      # like people's names, teams, and points.
      def create_competition_results_for(results, race)
        results.each do |result|
          competition_result = ::Result.create!(
            :place                   => result.place,
            :person_id               => person_id_for_competition_result(result),
            :team_id                 => team_id_for_competition_result(result, team_ids_by_person_id_hash(results)),
            :event                   => self,
            :race                    => race,
            :competition_result      => true,
            :team_competition_result => team?,
            :points                  => result.points
          )
       
          result.scores.each do |score|
            create_score competition_result, score.source_result_id, score.points
          end
        end

        true
      end

      # Competition results could know they need to lookup their team
      # Can move to Result?
      def team_ids_by_person_id_hash(results)
        hash = Hash.new
        ::Person.select("id, team_id").where("id in (?)", results.map(&:participant_id).uniq).map do |person|
          hash[person.id] = person.team_id
        end
        hash
      end

      # This is always the 'best' result
      def create_score(competition_result, source_result_id, points)
        ::Score.create!(
          :source_result_id => source_result_id, 
          :competition_result_id => competition_result.id, 
          :points => points
        )
      end
      
      def person_id_for_competition_result(result)
        if team?
          nil
        else
          result.participant_id
        end
      end
      
      def team_id_for_competition_result(result, team_ids)
        if team?
          result.participant_id
        else
          team_ids[result.participant_id]
        end
      end
    end
  end
end
