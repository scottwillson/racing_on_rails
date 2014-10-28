require_relative "place"
require_relative "rules"
require_relative "select_results"
require_relative "select_scores"
require_relative "structs"

module Competitions
  module Calculations
    # Stateless, functional-style competition calculations. No dependencies on database or Rails.
    # Given source results as an Array of Hashes, returns competition results as an Array of Hashes.
    # Responsible for result eligibility, points, placing and person or team identity.
    # Not responsible for display data like people's names or teams.
    #
    # Use participant_id instead of person_id or team_id. People and teams are treated the same in calculations.
    # "Participant" means "someone or some people who at least started a race and show up in the results"
    #
    # Non-scoring results from the same race need to be passed in for team size calculations.
    module Calculator
      UNLIMITED = Float::INFINITY

      # Transfrom +results+ (Array of Hashes) into competition results
      # +rules+:
      # * break_ties: true/false. Default to false. Apply tie-breaking rules to results with same points.
      # * dnf: true/false. Count DNFs? Default to true.
      # * field_size_bonus: true/false. Default to false. Give 1.5 X points for fields of 75 or more
      # * maximum_events: 1 to UNLIMITED. Only score results up to +maximum_events+ count. For rules like: best 7 of 8.
      # * members_only: true/false. Default to true. Only members are counted.
      # * results_per_event: integer. Default to UNLIMITED. How many results in the same event are counted for a participant?
      # * results_per_race: integer. Default to 1. How many results in the same race are counted for a participant?
      #   Used for team competitions. Team is the participant.
      # * point_schedule: 0-based Array of points for result place. Default to nil (all results receive one point).
      #                    First place gets points at point_schedule[0].
      # * source_event_ids: Array of event IDs. Only consider results from this event. Default to nil: all results eligible.
      # * team: true/false. Default to false. Team-based competition?
      # * use_source_result_points: true/false. Default to false. Don't calculate points. Use points from scoring result.
      #   Used by OBRA Overall and Age-Graded BARs.
      #
      # Replace nil values and missing keys with defaults. E.g., dnf: nil becomes dnf: true.
      #
      # Points are multiplied by Struct::CalculatorResult :multiplier. Use for "double points" events. Relies on denormalized
      # results setting multipler. Could pass in a map of event_id: multiplier instead?
      #
      # Competitions that have a field_size_bonus need to set CalculatorResult::field_size.
      def self.calculate(results, rules = {})
        rules = default_rules_merge(rules)
      
        results = map_hashes_to_results(results)
        results = add_team_sizes(results, rules)
        results = select_results(results, rules)
        scores  = map_to_scores(results, rules)
        scores  = select_scores(scores, rules)
        results = map_to_results(scores)

        place results, rules
      end
    
      # Create Struct::CalculatorResults from Hashes
      def self.map_hashes_to_results(results)
        results.map do |result|
          new_result = Struct::CalculatorResult.new
          result.each_pair do |key, value|
            new_result[key] = value
          end
          new_result
        end
      end

      def self.add_team_sizes(results, rules)
        # No point in figuring team size if just reusing points
        if rules[:use_source_result_points]
          return results
        end

        # Use race and place as a key: Array of race_id and place_id
        results_by_race_and_place = Hash.new
        results.group_by { |r| [ r.race_id, r.place ] }.
        each { |key, results_with_same_place| results_by_race_and_place[key] = results_with_same_place.size }

        results.map do |result|
          merge_struct(result, team_size: results_by_race_and_place[[ result.race_id, result.place ]])
        end
      end

      # Create Struct::CalculatorScores from Struct::CalculatorResults. Set points for each score.
      def self.map_to_scores(results, rules)
        results.map do |result|
          Struct::CalculatorScore.new.tap do |new_score|
            new_score.date             = result.date
            new_score.numeric_place    = numeric_place(result)
            new_score.source_result_id = result.id
            new_score.participant_id   = result.participant_id
            new_score.points           = points(result, rules)
          end
        end
      end
    
      # Create competion results as Array of Struct::CalculatorResults from Struct::CalculatorScores.
      def self.map_to_results(scores)
        scores.group_by { |r| r.participant_id }.map do |participant_id, person_scores|
          Struct::CalculatorResult.new.tap do |new_result|
            new_result.participant_id = participant_id
            new_result.points         = person_scores.map(&:points).inject(:+)
            new_result.scores         = person_scores
          end
        end
      end

      def self.points(result, rules)
        if rules[:use_source_result_points]
          return result.points
        end

        if numeric_place(result) < Float::INFINITY
          if rules[:point_schedule]
            if (result.multiplier.nil? || result.multiplier == 1) && rules[:field_size_bonus] && result.field_size >= 75
              field_size_multiplier = 1.5
            else
              field_size_multiplier = 1.0
            end

            ((rules[:point_schedule][numeric_place(result) - 1] || 0) /
            (result.team_size || 1.0).to_f) *
            (result.multiplier || 1 ).to_f *
            field_size_multiplier
          else
            1
          end
        elsif rules[:dnf] && result.place == "DNF"
          1
        else
          0
        end
      end
    end
  end
end
