# frozen_string_literal: true

module Competitions
  module Bars
    module Categories
      def categories_for(race)
        # Really should remove all other top-level categories and their descendants?
        cats = [ race.category ] + race.category.descendants

        if race.category.name == "Masters Men"
          masters_men_4_5 = ::Category.find_by_name("Masters Men 4/5")
          if masters_men_4_5
            cats.delete masters_men_4_5
            cats = cats - masters_men_4_5.descendants
          end
        end

        if race.category.name == "Masters Women"
          masters_women_4 = ::Category.find_by_name("Masters Women 4")
          if masters_women_4
            cats.delete masters_women_4
            cats = cats - masters_women_4.descendants
          end
        end

        cats
      end
    end
  end
end
