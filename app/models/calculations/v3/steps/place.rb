# frozen_string_literal: true

module Calculations
  module V3
    module Steps
      module Place
        def self.calculate!(calculator)
          calculator.event_categories.each do |category|
            place = 1
            previous_result = nil

            sort_by_points(results, rules[:break_ties], rules[:most_points_win]).map.with_index do |result, index|
              if index == 0
                place = 1
              elsif result.points != previous_result.points
                place = index + 1
              elsif rules[:break_ties] && (!result.tied || !previous_result.tied)
                place = index + 1
              end
              previous_result = result
              merge_struct result, place: place
            end


            place = 0
            category.results.sort_by!(&:points).reverse!.each do |result|
              next if category.rejected?

              place += 1
              result.place = place.to_s
            end
          end
        end
      end
    end
  end
end
