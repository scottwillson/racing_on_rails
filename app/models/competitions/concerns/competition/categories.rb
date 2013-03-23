module Concerns
  module Competition
    module Categories
      def category_names
        [ friendly_name ]
      end

      # Only consider results from categories. Default to false: use all races in year.
      def categories?
        false
      end

      # Array of ids (integers)
      # +race+ category, +race+ category's siblings, and any competition categories
      def category_ids_for(race)
        [ race.category_id ] + race.category.descendants.map(&:id)
      end
    end
  end
end
