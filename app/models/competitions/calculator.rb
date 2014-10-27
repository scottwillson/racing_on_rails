module Competitions
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

    # Use simple datatypes with no behavior. Hash doesn't have method-like accessors, which means we
    # can't use symbol to proc. E.g., results.sort_by(&:points). OpenStruct is slow. Full-blown classes
    # are overkill. Could add methods to Struct using do…end, ActiveModels or maybe subclass Hash but Struct
    # works well.
    #
    # Struct::Result would clash with Active Record models so Structs are prefixed with "Calculator."

    # Source result or calculated competition result.
    # +tied+ is plumbing set during calculation. If place method can't break a tie, results are marked as "tied" so they
    # are given the same points.
    #
    # +team_size+ is calculated here, too, though it could be passed in.
    Struct.new(
      "CalculatorResult",
      :bar, :multiplier, :category_id, :date, :date_of_birth, :event_id, :field_size, :id, :ironman,
      :member_from, :member_to, :participant_id, :place, :points, :race_id, :sanctioned_by, :scores,
      :team_member, :team_size, :tied, :type, :year
    )

    # Ties a source result to a competition result.
    # CalculatorScore#numeric_place is source result's place
    Struct.new("CalculatorScore", :date, :numeric_place, :participant_id, :points, :source_result_id, :team_size)

    # Transfrom +source_results+ (Array of Hashes) into competition results
    # +options+:
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
    # Points are multiplied by Struct::CalculatorResult :multiplier. Use for "double points" events. Relies on denormalized
    # results setting multipler. Could pass in a map of event_id: multiplier instead?
    #
    # Competitions that have a field_size_bonus need to set CalculatorResult::field_size
    def self.calculate(source_results, options = {})
      assert_valid_options options

      break_ties               = options.has_key?(:break_ties) ? options[:break_ties] : false
      dnf                      = options.has_key?(:dnf) ? options[:dnf] : false
      field_size_bonus         = options.has_key?(:field_size) ? options[:field_size] : false
      maximum_events           = options[:maximum_events] || UNLIMITED
      members_only             = options.has_key?(:members_only) ? options[:members_only] : true
      point_schedule           = options[:point_schedule]
      results_per_event        = options[:results_per_event] || UNLIMITED
      results_per_race         = options[:results_per_race] || 1
      source_event_ids         = options[:source_event_ids]
      team                     = options.has_key?(:team) ? options[:team] : false
      use_source_result_points = options.has_key?(:use_source_result_points) ? options[:use_source_result_points] : false

      struct_results = map_hashes_to_results(source_results)
      results_with_team_sizes = add_team_sizes(struct_results, use_source_result_points)
      eligible_results = select_eligible(results_with_team_sizes, results_per_event, results_per_race, members_only, team, source_event_ids)

      # The whole point: generate scores from sources results and competition results from scores
      scores = map_to_scores(eligible_results, point_schedule, dnf, field_size_bonus, use_source_result_points)
      scores_with_points = scores.select { |s| s.points && s.points > 0.0 && s.participant_id }
      scores_with_points = reject_scores_greater_than_maximum_events(scores_with_points, maximum_events)
      competition_results = map_to_results(scores_with_points)

      place competition_results, break_ties
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

    def self.add_team_sizes(results, use_source_result_points = false)
      # No point in figuring team size if just reusing points
      if use_source_result_points
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

    # Apply rules. Example: DNS or numeric place? Person is a member for this year?
    # It's somewhat arbritrary which elgilibilty rules are applied here, and which were applied by
    # the calling Competition when it selected results from the database.
    # Only keep best +results_per_event+ results for participant (person or team).
    def self.select_eligible(results, results_per_event = UNLIMITED, results_per_race = 1, members_only = true, team = false, source_event_ids = nil)
      results = results.select { |r| r.participant_id && ![ nil, "", "DQ", "DNS" ].include?(r.place) }

      if members_only && team
        results = results.select(&:team_member)
      end

      if members_only
        results = results.select { |r| member_in_year?(r) }
      end

      if source_event_ids
        results = results.select { |r| source_event_ids.include? r.event_id }
      end

      results = select_results_for_event(results, results_per_event)
      select_results_for_race(results, results_per_race)
    end

    def self.select_results_for_event(results, results_per_event)
      if results_per_event == UNLIMITED
        results
      else
        results.group_by { |r| [ r.participant_id, r.event_id ] }.
        map do |key, r|
          r.sort_by { |r2| numeric_place(r2) }[0, results_per_event]
        end.
        flatten
      end
    end

    def self.select_results_for_race(results, results_per_race)
      if results_per_race == UNLIMITED
        results
      else
        results.group_by { |r| [ r.participant_id, r.race_id ] }.
        map do |key, r|
          r.sort_by { |r2| numeric_place(r2) }[0, results_per_race]
        end.
        flatten
      end
    end

    # Create Struct::CalculatorScores from Struct::CalculatorResults. Set points for each score.
    def self.map_to_scores(results, point_schedule, dnf, field_size_bonus = false, use_source_result_points = false)
      results.map do |result|
        Struct::CalculatorScore.new.tap do |new_score|
          new_score.date             = result.date
          new_score.numeric_place    = numeric_place(result)
          new_score.source_result_id = result.id
          new_score.participant_id   = result.participant_id
          new_score.points           = points(result, point_schedule, dnf, field_size_bonus, use_source_result_points)
        end
      end
    end

    def self.reject_scores_greater_than_maximum_events(scores, maximum_events = UNLIMITED)
      if maximum_events == UNLIMITED
        scores
      else
        scores.group_by(&:participant_id).
        map do |participant_id, participant_scores|
          participant_scores.sort_by(&:points).reverse[ 0, maximum_events ]
        end.
        flatten
      end
    end

    # Create competion results as Array of Struct::CalculatorResults from Struct::CalculatorScores.
    def self.map_to_results(scores)
      scores.group_by { |r| r.participant_id }.map do |participant_id, person_scores|
        Struct::CalculatorResult.new.tap do |new_result|
          new_result.participant_id = participant_id
          new_result.points    = person_scores.map(&:points).inject(:+)
          new_result.scores    = person_scores
        end
      end
    end

    # Set place on array of CalculatorResults
    def self.place(results, break_ties = false)
      place = 1
      previous_result = nil

      sort_by_points(results, break_ties).map.with_index do |result, index|
        if index == 0
          place = 1
        elsif result.points < previous_result.points
          place = index + 1
        elsif break_ties && (!result.tied || !previous_result.tied)
          place = index + 1
        end

        previous_result = result
        merge_struct(result, place: place)
      end
    end

    # Result places are represented as Strings, even "1", "2", etc. Convert "1" to 1 and DNF, DQ, etc. to Infinity.
    # Infinity convention is handy for sorting.
    def self.numeric_place(result)
      if result.place && result.place.to_i > 0
        result.place.to_i
      else
        Float::INFINITY
      end
    end

    def self.sort_by_points(results, break_ties = false)
      if break_ties
        results.sort do |x, y|
          compare_by_points x, y
        end
      else
        results.sort_by(&:points).reverse
      end
    end

    def self.compare_by_points(x, y)
      diff = y.points <=> x.points
      return diff if diff != 0

      diff = compare_by_best_place(x, y)
      return diff if diff != 0

      diff = compare_by_most_recent_result(x, y)
      return diff if diff != 0

      # Special-case. Tie cannot be broken.
      x.tied = true
      y.tied = true
      0
    end

    def self.compare_by_best_place(x, y)
      return 0 if x.scores.nil? && y.scores.nil?
      return 0 if x.scores.size == 0 && y.scores.size == 0

      x_places = (x.scores || []).map(&:numeric_place).sort.reverse
      y_places = (y.scores || []).map(&:numeric_place).sort.reverse

      while x_places.size > 0 || y_places.size > 0 do
        x_place = x_places.pop
        y_place = y_places.pop

        if x_place.nil? && y_place.nil?
          return 0
        elsif x_place.nil?
          return 1
        elsif y_place.nil?
          return -1
        else
          diff = x_place <=> y_place
          return diff if diff != 0
        end
      end
      0
    end

    def self.compare_by_most_recent_result(x, y)
      return 0 if x.scores.nil? && y.scores.nil?

      x_date = x.scores.map(&:date).max
      y_date = y.scores.map(&:date).max

      if x_date.nil? && y_date.nil?
        0
      elsif x_date.nil?
        1
      elsif y_date.nil?
        -1
      else
        y_date <=> x_date
      end
    end

    def self.points(result, point_schedule = nil, dnf = false, field_size_bonus = false, use_source_result_points = false)
      if use_source_result_points
        return result.points
      end

      if numeric_place(result) < Float::INFINITY
        if point_schedule
          if (result.multiplier.nil? || result.multiplier == 1) && field_size_bonus && result.field_size >= 75
            field_size_multiplier = 1.5
          else
            field_size_multiplier = 1.0
          end

          ((point_schedule[numeric_place(result) - 1] || 0) /
          (result.team_size || 1.0).to_f) *
          (result.multiplier || 1 ).to_f *
          field_size_multiplier
        else
          1
        end
      elsif dnf && result.place == "DNF"
        1
      else
        0
      end
    end

    def self.team_size(result, results)
      results.count { |r| r.race_id == result.race_id && r.place == result.place }
    end

    def self.member_in_year?(result)
      raise(ArgumentError, "Result year required to check membership") unless result.year
      result.member_from && result.member_to && result.member_from.year <= result.year && result.member_to.year >= result.year
    end

    def self.valid_options
      [ :break_ties, :dnf, :field_size_bonus, :maximum_events, :members_only, :results_per_event, :results_per_race,
        :point_schedule, :source_event_ids, :team, :use_source_result_points ]
    end

    def self.assert_valid_options(options)
      return true if !options || options.size == 0

      options.keys.each do |key|
        if !valid_options.include?(key)
          raise "#{key} is not a valid option for Calculator. Valid: #{valid_options}"
        end
      end
    end

    # Create new copy of a Struct with +attributes+
    def self.merge_struct(struct, attributes)
      new_struct = struct.dup
      attributes.each do |k, v|
        new_struct[k] = v
      end
      new_struct
    end
  end
end
