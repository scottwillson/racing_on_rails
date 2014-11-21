require_relative "place"
require_relative "rules"
require_relative "select_results"
require_relative "select_scores"
require_relative "structs"

module Competitions
  module Calculations
    UNLIMITED = Float::INFINITY

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
      extend Place
      extend Rules
      extend SelectResults
      extend SelectScores
      extend Structs

      # Transfrom +results+ (Array of Hashes) into competition results
      # +rules+:
      # * break_ties: boolean. Default to false. Apply tie-breaking rules to results with same points.
      # * completed_events: integer. Default to nil. How many events in the competition have results?
      #   Not a 'rule' but needs to be calculated from all categories. Only required for
      #   competitions with +minimum_events+.
      #   (One category/race may not have results for one event. Passing in *all* results for all races/categories
      #   is a better solution, but means Calculator would use a more complicated data structure: hash instead of an array.)
      # * dnf_points: float. Points for DNF. Default to 0.
      # * end_date: Default to nil. Is this result from the last event?
      # * field_size_bonus: boolean. Default to false. Give 1.5 X points for fields of 75 or more
      # * maximum_events: 1 to UNLIMITED. Only score results up to +maximum_events+ count. For rules like: best 7 of 8.
      # * minimum_events: integer. Only score if +minimum_events+ results. Default to nil.
      # * missing_result_penalty: integer. Default nil. For fewest-points wins competitions. Give penalty for if a participant
      #   has fewer than results_per_event.
      # * members_only: boolean. Default to true. Only members are counted.
      # * most_points_win: true/boolean. Default to true. For fewest-points wins competitions.
      # * results_per_event: integer. Default to UNLIMITED. How many results in the same event are counted for a participant?
      # * results_per_race: integer. Default to 1. How many results in the same race are counted for a participant?
      #   Used for team competitions. Team is the participant.
      # * point_schedule: 0-based Array of points for result place. Default to nil (all results receive one point).
      #                    First place gets points at point_schedule[0].
      # * points_schedule_from_field_size: boolean. Default to false. Assign points based on field size.
      # * source_event_ids: Array of event IDs. Only consider results from this event. Default to nil: all results eligible.
      # * team: boolean. Default to false. Team-based competition?
      # * use_source_result_points: boolean. Default to false. Don't calculate points. Use points from scoring result.
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
        results = apply_team_sizes results, rules
        results = select_results   results, rules
        scores  = map_to_scores    results, rules
        scores  = select_scores    scores,  rules
        results = map_to_results   scores,  rules
                  apply_place      results, rules
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

      def self.apply_team_sizes(results, rules)
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
        end +
        add_missing_result_penalty_scores(results, rules)
      end

      def self.add_missing_result_penalty_scores(results, rules)
        return [] if rules[:missing_result_penalty].nil?

        missing_scores = []
        results.group_by(&:participant_id).
        each do |participant_id, participant_results|
          if participant_results.size < rules[:results_per_event] * rules[:completed_events]
            missing_scores << Struct::CalculatorScore.new.tap do |new_score|
              new_score.date             = rules[:end_date]
              new_score.numeric_place    = rules[:missing_result_penalty]
              new_score.participant_id   = participant_id
              new_score.points           = ((rules[:results_per_event] * rules[:completed_events]) - participant_results.size) * rules[:missing_result_penalty]
            end
          end
        end

        missing_scores
      end

      # Create competion results as Array of Struct::CalculatorResults from Struct::CalculatorScores.
      def self.map_to_results(scores, rules)
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
          if rules[:point_schedule] || rules[:points_schedule_from_field_size]
            points_from_point_schedule result, rules
          else
            1
          end
        elsif rules[:dnf_points] && result.place == "DNF"
          rules[:dnf_points]
        else
          0
        end
      end

      def self.points_from_point_schedule(result, rules)
        if rules[:missing_result_penalty] && numeric_place(result) > rules[:missing_result_penalty]
          return rules[:missing_result_penalty]
        end

        if rules[:points_schedule_from_field_size]
          base_points = (result.field_size - numeric_place(result)) + 1
        else
          base_points = rules[:point_schedule][numeric_place(result) - 1]
        end

        (((base_points || 0)) / (result.team_size || 1.0).to_f) *
        (result.multiplier || 1 ).to_f *
        last_event_multiplier(result, rules) *
        field_size_multiplier(result, rules[:field_size_bonus])
      end

      def self.last_event_multiplier(result, rules)
        if rules[:double_points_for_last_event] && last_event?(result, rules)
          2
        else
          1
        end
      end

      def self.last_event?(result, rules)
        raise(ArgumentError, "End date required to check for last event") unless rules[:end_date]
        result.date == rules[:end_date]
      end

      def self.field_size_multiplier(result, field_size_bonus)
        if (result.multiplier.nil? || result.multiplier == 1) && field_size_bonus && result.field_size >= 75
          1.5
        else
          1.0
        end
      end

      # Mark results as preliminary, if there is a minimum number of events
      def self.apply_preliminary(results, rules)
        return results if rules[:minimum_events].nil? || event_complete?(rules) || rules[:completed_events] < rules[:minimum_events]

        results.map do |r|
          merge_struct r, preliminary: preliminary?(r.scores, rules)
        end
      end

      def self.preliminary?(scores, rules)
        scores.size < rules[:minimum_events]
      end

      def self.event_complete?(rules)
        rules[:completed_events] && rules[:source_event_ids] && rules[:completed_events] == rules[:source_event_ids].size
      end
    end
  end
end
