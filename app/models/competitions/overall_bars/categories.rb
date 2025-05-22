# frozen_string_literal: true

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
            event.categories.min
        else
          category
        end
      end

      # Really should remove all other top-level categories and their descendants?
      def categories_for(race)
        categories = [race.category] + race.category.descendants

        # Masters Men exclusions
        if race.category.name == "Masters Men"
          masters_men_4_5 = ::Category.find_by(name: "Masters Men 4/5")
          if masters_men_4_5
            categories.delete masters_men_4_5
            categories -= masters_men_4_5.descendants
          end
        end

        # Masters Women exclusions  
        if race.category.name == "Masters Women"
          masters_women_4 = ::Category.find_by(name: "Masters Women 4")
          if masters_women_4
            categories.delete masters_women_4
            categories -= masters_women_4.descendants
          end
        end

        # Category 3 Men inclusions for Category 2/3 mapping
        categories << ::Category.find_by(name: "Category 2/3 Men") if race.category.name == "Category 3 Men"
        categories.delete ::Category.find_by(name: "Category 2/3 Men") if race.category.name == "Senior Men"

        # Singlespeed mappings for 2025+ (include historical data)
        if race.category.name == "Singlespeed"
          # Include the old combined category for historical data
          old_singlespeed = ::Category.find_by(name: "Singlespeed/Fixed")
          categories << old_singlespeed if old_singlespeed

          # Also include any other singlespeed variations for men
          singlespeed_men_variations = ::Category.where(
            "name LIKE '%inglespeed%' AND (gender = 'M' OR gender IS NULL OR name NOT LIKE '%Women%')"
          ).where.not(name: "Singlespeed Women")
          categories += singlespeed_men_variations
        end

        if race.category.name == "Singlespeed Women"
          # Include the old combined category for historical data (women raced here too)
          old_singlespeed = ::Category.find_by(name: "Singlespeed/Fixed")
          categories << old_singlespeed if old_singlespeed

          # Include any other women's singlespeed variations
          singlespeed_women_variations = ::Category.where(
            "name LIKE '%inglespeed%' AND (gender = 'F' OR name LIKE '%Women%')"
          )
          categories += singlespeed_women_variations
        end

        categories.compact.uniq
      end

      def find_category(name)
        ::Category.find_by name: name
      end
    end
  end
end
