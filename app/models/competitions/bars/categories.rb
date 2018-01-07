# frozen_string_literal: true

module Competitions
  module Bars
    module Categories
      def categories_for(race)
        # Really should remove all other top-level categories and their descendants?
        cats = [race.category] + race.category.descendants

        if race.category.name == "Masters Men"
          masters_men_4_5 = ::Category.find_by(name: "Masters Men 4/5")
          if masters_men_4_5
            cats.delete masters_men_4_5
            cats -= masters_men_4_5.descendants
          end
        end

        if race.category.name == "Masters Women"
          masters_women_4 = ::Category.find_by(name: "Masters Women 4")
          if masters_women_4
            cats.delete masters_women_4
            cats -= masters_women_4.descendants
          end
        end

        if race.category.name == "Category 2/3 Men" && race.discipline == "Cyclocross"
          cats << ::Category.find_by(name: "Category 3 Men")
          cats << ::Category.find_by(name: "Men 3")
        end

        if race.category.name == "Category 1/2 Men" && race.discipline == "Cyclocross"
          cats.delete ::Category.find_by(name: "Category 3 Men")
          cats.delete ::Category.find_by(name: "Men 3")
        end

        cats
      end
    end
  end
end
