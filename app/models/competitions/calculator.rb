module Competitions
  # Stateless, functional-style competition calculations. No dependencies on database or Rails.
  # Given source results as an Array of Hashes, returns competition results as an Array of Hashes.
  # Responsible for result eligibility, points, placing and person or team identity.
  # Not responsible for display data like people's names or teams.
  module Calculator

    # Use simple datatypes with no behavior. Hash doesn't have method-like accessors, which means we
    # can't use symbol to proc. E.g., results.sort_by(&:points). OpenStruct is slow. Full-blown classes 
    # are overkill. Could add methods to Struct using do…end, ActiveModels or maybe subclass Hash but Struct 
    # works well.
    #
    # Struct::Result would clash with Active Record models so Structs are prefixed with "Calculator."

    # Source result or calculated competition result
    Struct.new(
      "CalculatorResult", 
      :date, :event_id, :id, :member_from, :member_to, :person_id, :place, :points, :race_id, :scores, :team_id
    )
    
    # Ties a source result to a competition result
    Struct.new("CalculatorScore", :person_id, :points, :source_result_id)

    # Transfrom +source_results+ (Array of Hashes) into competition results
    # +options+:
    # * dnf: true/false. Count DNFs? Defaults to true.
    # * points_schedule: 0-based Array of points for result place. Defaults to nil (all results receive one point). 
    #                    First place gets points at points_schedule[0].
    def self.calculate(source_results, options = {})
      points_schedule = options[:points_schedule]
      dnf = options[:dnf] || false

      struct_results = map_hashes_to_results(source_results)
      eligible_results = select_eligible(struct_results)

      # The whole point: generate scors from sources results and competition results from scores
      scores = map_to_scores(eligible_results, points_schedule, dnf)
      competition_results = map_to_results(scores)
      
      # Only keep results that earned points and belong to someone
      results_with_points = competition_results.reject { |r| r.points.nil? || r.points <= 0.0 || r.person_id.nil? }
      
      place results_with_points
    end

    # Apply rules. Example: DNS or numeric place? Person is a member for this year?
    # It's somewhat arbritrary which elgilibilty rules are applied here, and which were applied by
    # the calling Competition when it selected results from the database.
    def self.select_eligible(results)
      results.
      select { |r| r.person_id && ![ nil, "", "DQ", "DNS" ].include?(r.place) }.
      select { |r| member_in_year?(r) }.
      # Only keep the best result for each race
      group_by { |r| [ r.person_id, r.race_id ] }.
      map do |key, r|
        r.min_by { |r2| numeric_place(r2) }
      end
    end

    # Create Struct::CalculatorScores from Struct::CalculatorResults. Set points for each score.
    def self.map_to_scores(results, points_schedule, dnf)
      results.map do |result|
        Struct::CalculatorScore.new.tap do |new_score|
          new_score.source_result_id = result.id
          new_score.person_id        = result.person_id
          new_score.points           = points(result, points_schedule, dnf)
        end
      end
    end

    # Create competion results as Array of Struct::CalculatorResults from Struct::CalculatorScores.
    def self.map_to_results(scores)
      scores.group_by { |r| r.person_id }.map do |person_id, person_scores|
        Struct::CalculatorResult.new.tap do |new_result|
          new_result.person_id = person_id
          new_result.points    = person_scores.map(&:points).inject(:+)
          new_result.scores    = person_scores
        end
      end
    end

    # Set place on array of CalculatorResults
    def self.place(results)
      previous_result = nil
      place = 1

      results.sort_by(&:points).reverse.map.with_index do |r, index|
        if previous_result && r.points < previous_result.points
          place = index + 1
        end
        previous_result = r

        Struct::CalculatorResult.new.tap do |new_result|
          new_result.person_id = r.person_id
          new_result.place     = place
          new_result.points    = r.points
          new_result.scores    = r.scores
        end
      end
    end

    def self.points(result, points_schedule, dnf)
      if numeric_place(result) < Float::INFINITY
        1
      elsif dnf && result.place == "DNF"
        1
      else
        0
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
    
    def self.member_in_year?(result)
      result.member_from && result.member_to && result.member_from.year <= Date.today.year && result.member_to.year >= Date.today.year
    end
  end
end
