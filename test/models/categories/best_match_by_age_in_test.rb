# frozen_string_literal: true

require "test_helper"

module Competitions
  # :stopdoc:
  class BestMatchByAgeTest < ActiveSupport::TestCase
    test "ages" do
      athena = ::Category.find_or_create_by_normalized_name("Athena")
      junior_men_17_18 = ::Category.find_or_create_by_normalized_name("Junior Men 17-18")
      men_9_18 = ::Category.find_or_create_by_normalized_name("Men 9-18")
      men_35_49 = ::Category.find_or_create_by_normalized_name("Men 35-49")
      women_35_49 = ::Category.find_or_create_by_normalized_name("Women 35-49")

      event = FactoryBot.create(:event)
      event.races.create!(category: men_9_18)
      event.races.create!(category: men_35_49)
      event.races.create!(category: women_35_49)

      assert_best_match_by_age_in [athena, women_35_49], women_35_49, event, 35
      assert_best_match_by_age_in [junior_men_17_18, men_9_18], men_9_18, event, 35
    end

    test "equipment" do
      singlespeed = ::Category.find_or_create_by_normalized_name("Singlespeed")
      men_35_49 = ::Category.find_or_create_by_normalized_name("Men 35-49")
      masters_35_1_2 = ::Category.find_or_create_by_normalized_name("Masters 35+ 1/2")

      event = FactoryBot.create(:event)
      event.races.create!(category: men_35_49)

      assert_best_match_by_age_in [masters_35_1_2, men_35_49, singlespeed], men_35_49, event, 45
    end

    def assert_best_match_by_age_in(categories, race_category, event, result_age = nil)
      categories.each do |category|
        best_match = category.best_match_by_age_in(event.categories, result_age)
        assert race_category == best_match,
               "#{race_category.name} should be best_match_in for #{category.name} in event with " \
               "categories #{event.races.map(&:name).join(', ')} but was #{best_match&.name}"
      end

      event.categories
           .reject { |category| category.in?(categories) }
           .each do |category|
             best_match = category.best_match_in(event.categories)
             assert race_category != best_match,
                    "Did not expect #{race_category.name} to match #{category.name} in event with " \
                    "categories #{event.races.map(&:name).join(', ')}, but was #{best_match.name}"
           end
    end
  end
end
