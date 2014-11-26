# TODO Delete
module Competitions
  module OverallBars
    module Categories
      extend ActiveSupport::Concern

      def equivalent_category_for(category_friendly_param, discipline)
        return nil unless category_friendly_param && discipline

        if discipline == Discipline[:overall]
          event = self
        else
          event = children.detect { |child| child.discipline == discipline.name }
          return unless event
        end

        category = event.categories.detect { |cat| cat.friendly_param == category_friendly_param }

        if category.nil?
          event.categories.detect { |cat| cat.friendly_param == category_friendly_param || cat.parent.friendly_param == category_friendly_param } ||
            event.categories.sort.first
        else
          category
        end
      end

      # Really should remove all other top-level categories and their descendants?
      def categories_for(race)
        categories = [ race.category ] + race.category.descendants

        if race.category.name == "Masters Men"
          masters_men_4_5 = ::Category.find_by_name("Masters Men 4/5")
          if masters_men_4_5
            categories.delete masters_men_4_5
            categories = categories - masters_men_4_5.descendants
          end
        end

        if race.category.name == "Masters Women"
          masters_women_4 = ::Category.find_by_name("Masters Women 4")
          if masters_women_4
            categories.delete masters_women_4
            categories = categories - masters_women_4.descendants
          end
        end

        categories
      end

      def find_category(name)
        ::Category.find_by_name name
      end
    end
  end
end
