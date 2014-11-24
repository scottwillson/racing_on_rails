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

        # Cat 4/5 is a special case. Can't config in database because it's a circular relationship.
        category_4_5_men = ::Category.find_by_name("Category 4/5 Men")
        category_4_men = ::Category.find_by_name("Category 4 Men")
        if category_4_5_men && category_4_men && race.category == category_4_men
          cats << category_4_5_men
        end

        cats
      end
    end
  end
end
