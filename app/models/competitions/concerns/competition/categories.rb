module Concerns
  module Competition
    module Categories
      # Array of ids (integers)
      # +race+ category, +race+ category's siblings, and any competition categories
      def category_ids_for(race)
        [ race.category_id ] + race.category.descendants.map(&:id)
      end
    end
  end
end
