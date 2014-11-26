module Competitions
  module Categories
    # Competition's races. Default to +category_names+ (e.g., Men A, Men B, …)
    # But some competitions have race names like "Team" or "Overall" drawn
    # from +source_result_category_names+.
    def race_category_names
      category_names
    end

    # Consider results from these categories
    # TODO Use or remove
    def source_result_category_names
      category_names
    end

    def category_names
      [ friendly_name ]
    end

    # Only consider results from categories. Default to false: use all races in year.
    def categories?
      false
    end

    # Array of ids (integers)
    # +race+ category, +race+ category's siblings, and any competition categories
    def categories_for(race)
      [ race.category ] + race.category.descendants
    end
  end
end
