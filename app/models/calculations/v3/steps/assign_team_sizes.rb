# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module AssignTeamSizes
        def self.calculate!(calculator)
          # Discipline BARs with few source events look like team results because
          # they have many people with the same place. Don't apply a team size for
          # them when calculating the Overall BAR.
          return calculator.event_categories if calculator.rules.source_event_keys.any?

          # Use event_category and place as a key: Array of calculator and place_id
          results_by_category_and_place = {}

          calculator
            .source_results
            .group_by { |r| [r.event_category, r.place] }
            .each { |key, results_with_same_place| results_by_category_and_place[key] = results_with_same_place.size }

          # For efficiency, calculate which categories are team races outside of loop
          team_categories = team_categories(calculator.source_results)

          calculator.source_results.each do |result|
            if team_categories.include?(result.event_category)
              result.team_size = results_by_category_and_place[[result.event_category, result.place]]
            end
          end

          calculator.event_categories
        end

        def self.team_categories(results)
          results.group_by(&:event_category).select do |category, race_results|
            team_race? race_results
          end.keys
        end

        def self.team_race?(results)
          teams = teams(results)
          ratio = teams / unique_places(results)
          teams > 0 && ratio > 0.5
        end

        def self.unique_places(results)
          results.map(&:place).uniq.size.to_f
        end

        def self.teams(results)
          results.group_by(&:place).values.count { |r| r.size > 1 }
        end
      end
    end
  end
end
