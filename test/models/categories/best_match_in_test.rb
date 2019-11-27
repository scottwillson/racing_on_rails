# frozen_string_literal: true

require "test_helper"

module Competitions
  # :stopdoc:
  class BestMatchInTest < ActiveSupport::TestCase
    setup do
      @senior_men = Category.find_or_create_by_normalized_name("Senior Men")
      @cat_1 = Category.find_or_create_by_normalized_name("Category 1")
      @cat_1_2 = Category.find_or_create_by_normalized_name("Category 1/2")
      @cat_1_2_3 = Category.find_or_create_by_normalized_name("Category 1/2/3")
      @pro_1_2 = Category.find_or_create_by_normalized_name("Pro 1/2")
      @cat_2 = Category.find_or_create_by_normalized_name("Category 2")
      @cat_3 = Category.find_or_create_by_normalized_name("Category 3")
      @cat_3_4 = Category.find_or_create_by_normalized_name("Category 3/4")
      @cat_4 = Category.find_or_create_by_normalized_name("Category 4")
      @cat_4_women = Category.find_or_create_by_normalized_name("Category 4 Women")
      @cat_4_5_women = Category.find_or_create_by_normalized_name("Category 4/5 Women")
      @elite_men = Category.find_or_create_by_normalized_name("Elite Men")
      @pro_elite_men = Category.find_or_create_by_normalized_name("Pro Elite Men")
      @pro_cat_1 = Category.find_or_create_by_normalized_name("Pro/Category 1")
      @masters_men = Category.find_or_create_by_normalized_name("Masters Men")
      @masters_novice = Category.find_or_create_by_normalized_name("Masters Novice")
      @masters_men_4_5 = Category.find_or_create_by_normalized_name("Masters Men 4/5")
      @senior_women = Category.find_or_create_by_normalized_name("Senior Women")
      @junior_men = Category.find_or_create_by_normalized_name("Junior Men")
      @junior_women = Category.find_or_create_by_normalized_name("Junior Women")
      @junior_men_10_14 = Category.find_or_create_by_normalized_name("Junior Men 10-14")
      @junior_men_15_plus = Category.find_or_create_by_normalized_name("Junior 15+")
      @junior_men_3_4_5 = Category.find_or_create_by_normalized_name("Junior Men 3/4/5")
      @singlespeed = Category.find_or_create_by_normalized_name("Singlespeed/Fixed")
      @singlespeed_men = Category.find_or_create_by_normalized_name("Singlespeed Men")
      @singlespeed_women = Category.find_or_create_by_normalized_name("Singlespeed Women")
    end

    test "ability only" do
      event = FactoryBot.create(:event)
      event.races.create!(category: @cat_1)
      event.races.create!(category: @cat_2)
      event.races.create!(category: @cat_3)
      event.races.create!(category: @cat_4)

      assert_best_match_in [@cat_1, @cat_1_2, @cat_1_2_3], @cat_1, event
      assert_best_match_in [@cat_2], @cat_2, event
      assert_best_match_in [@cat_3, @cat_3_4, @junior_men_3_4_5], @cat_3, event
      assert_best_match_in [@cat_4, @cat_4_women, @cat_4_5_women, @masters_men_4_5], @cat_4, event
    end

    test "cyclocross categories" do
      event = FactoryBot.create(:event)
      cat_2_3 = Category.find_or_create_by_normalized_name("Category 2/3")
      cat_5 = Category.find_or_create_by_normalized_name("Category 5")

      event.races.create!(category: @cat_1_2)
      event.races.create!(category: cat_2_3)
      event.races.create!(category: @cat_3_4)
      event.races.create!(category: cat_5)

      assert_best_match_in [@cat_1, @cat_1_2, @cat_1_2_3, @cat_2], @cat_1_2, event
      assert_best_match_in [cat_2_3, @cat_3, @junior_men_3_4_5], cat_2_3, event
      assert_best_match_in [@cat_3_4, @cat_4, @cat_4_women, @cat_4_5_women, @masters_men_4_5], @cat_3_4, event
      assert_best_match_in [@masters_novice, cat_5], cat_5, event
    end

    test "ability + gender" do
      event = FactoryBot.create(:event)
      event.races.create!(category: @cat_1)
      event.races.create!(category: @cat_2)
      event.races.create!(category: @cat_3)
      event.races.create!(category: @cat_4)
      event.races.create!(category: @cat_4_5_women)

      assert_best_match_in [@cat_1, @cat_1_2, @cat_1_2_3], @cat_1, event
      assert_best_match_in [@cat_2], @cat_2, event
      assert_best_match_in [@cat_4, @masters_men_4_5], @cat_4, event
      assert_best_match_in [@cat_4_women, @cat_4_5_women], @cat_4_5_women, event
    end

    test "ages" do
      event = FactoryBot.create(:event)
      event.races.create!(category: @senior_men)
      event.races.create!(category: @senior_women)
      event.races.create!(category: @cat_3)
      event.races.create!(category: @cat_4)
      event.races.create!(category: @cat_4_women)
      event.races.create!(category: @masters_men)
      event.races.create!(category: @masters_men_4_5)
      event.races.create!(category: @junior_men)
      event.races.create!(category: @junior_women)

      assert_best_match_in [@senior_men, @cat_1, @cat_1_2, @cat_1_2_3, @pro_1_2, @cat_2, @pro_cat_1, @elite_men, @pro_elite_men], @senior_men, event
      assert_best_match_in [@senior_women], @senior_women, event
      assert_best_match_in [@cat_3, @cat_3_4], @cat_3, event
      assert_best_match_in [@cat_4], @cat_4, event
      assert_best_match_in [@cat_4_women, @cat_4_5_women], @cat_4_women, event
      assert_best_match_in [@masters_men], @masters_men, event
      assert_best_match_in [@masters_men_4_5, @masters_novice], @masters_men_4_5, event
      assert_best_match_in [@junior_men, @junior_men_10_14, @junior_men_15_plus, @junior_men_3_4_5], @junior_men, event
      assert_best_match_in [@junior_women], @junior_women, event
    end

    test "multiple 'and older' categories" do
      event = FactoryBot.create(:event)
      masters_men_50_plus = Category.find_or_create_by_normalized_name("Masters Men 50+")
      masters_men_60_plus = Category.find_or_create_by_normalized_name("Masters Men 60+")
      masters_men_70_plus = Category.find_or_create_by_normalized_name("Masters Men 70+")
      event.races.create!(category: masters_men_50_plus)
      event.races.create!(category: masters_men_60_plus)

      assert_best_match_in [masters_men_60_plus, masters_men_70_plus], masters_men_60_plus, event
    end

    test "multiple 'and older' categories for non-age" do
      event = FactoryBot.create(:event)
      masters_men_50_plus = Category.find_or_create_by_normalized_name("Masters Men 50+")
      masters_men_60_plus = Category.find_or_create_by_normalized_name("Masters Men 60+")
      men_5 = Category.find_or_create_by_normalized_name("Men 5")
      event.races.create!(category: masters_men_50_plus)
      event.races.create!(category: masters_men_60_plus)

      assert_best_match_in [men_5, masters_men_50_plus], masters_men_50_plus, event, 51
    end

    test "age range with 'and over'" do
      event = FactoryBot.create(:event)
      masters_men_50_plus = Category.find_or_create_by_normalized_name("Masters Men 50+")
      masters_men_60_plus = Category.find_or_create_by_normalized_name("Masters Men 60+")
      masters_men_60_69 = Category.find_or_create_by_normalized_name("Masters Men 60-69")
      event.races.create!(category: masters_men_50_plus)
      event.races.create!(category: masters_men_60_plus)

      assert_best_match_in [masters_men_60_plus, masters_men_60_69], masters_men_60_plus, event
    end

    test "ability and overlapping age" do
      event = FactoryBot.create(:event)
      masters_men_30_39 = Category.find_or_create_by_normalized_name("Masters Men 30-39")
      masters_men_35_39 = Category.find_or_create_by_normalized_name("Masters Men 35-39")
      masters_men_3_4_35 = Category.find_or_create_by_normalized_name("Masters 3/4 35+")
      event.races.create!(category: masters_men_30_39)
      event.races.create!(category: masters_men_35_39)

      assert_best_match_in [masters_men_3_4_35, masters_men_35_39], masters_men_35_39, event
    end

    test "equipment" do
      event = FactoryBot.create(:event)
      event.races.create!(category: @singlespeed)
      assert_best_match_in [@singlespeed, @singlespeed_men, @singlespeed_women], @singlespeed, event
    end

    test "equipment + gender" do
      event = FactoryBot.create(:event)
      event.races.create!(category: @singlespeed_men)
      event.races.create!(category: @singlespeed_women)

      assert_best_match_in [@singlespeed_men, @singlespeed], @singlespeed_men, event
      assert_best_match_in [@singlespeed_women], @singlespeed_women, event
    end

    test "consider equipment before ability" do
      event = FactoryBot.create(:event)

      fixed_gear = Category.find_or_create_by_normalized_name("Men Fixed Gear Open")
      event.races.create!(category: fixed_gear)

      men_1_2_3 = Category.find_or_create_by_normalized_name("Men 1/2/3")
      event.races.create!(category: men_1_2_3)

      assert_best_match_in [@senior_men, men_1_2_3], men_1_2_3, event
      assert_best_match_in [fixed_gear], fixed_gear, event
    end

    test "athena" do
      athena = ::Category.find_or_create_by_normalized_name("Athena")
      men_9_18 = ::Category.find_or_create_by_normalized_name("Men 9-18")
      women_35_49 = ::Category.find_or_create_by_normalized_name("Women 35-49")

      event = FactoryBot.create(:event)
      event.races.create!(category: men_9_18)
      event.races.create!(category: women_35_49)

      assert_best_match_in [athena, women_35_49], women_35_49, event, 35
    end

    test "gender over ability" do
      women_1_2_3 = Category.find_or_create_by_normalized_name("Women 1/2/3")

      event = FactoryBot.create(:event)
      event.races.create!(category: @pro_1_2)
      event.races.create!(category: Category.find_or_create_by_normalized_name("Pro/1/2 40+"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Pro/1/2 50+"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Category 3 Men"))
      event.races.create!(category: women_1_2_3)
      event.races.create!(category: Category.find_or_create_by_normalized_name("Women 4/5"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Masters Men 40-49 (Category 3/4/5)"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Masters Women 40+ (Category 3/4/5)"))
      event.races.create!(category: @junior_men)
      event.races.create!(category: @junior_women)

      women_1_2 = Category.find_or_create_by_normalized_name("Women 1/2")
      assert_best_match_in [women_1_2, women_1_2_3], women_1_2_3, event
    end

    test "bar categories" do
      junior_women_10_12 = Category.find_or_create_by_normalized_name("Junior Women 10-12")
      men_15_24 = Category.find_or_create_by_normalized_name("Men 15-24")

      event = FactoryBot.create(:event)
      event.races.create!(category: Category.find_or_create_by_normalized_name("Athena"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Clydesdale"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Category 3 Men"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Category 3 Women"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Category 4 Men"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Category 4 Women"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Category 5 Men"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Category 5 Women"))
      event.races.create!(category: @junior_men)
      event.races.create!(category: @junior_women)
      event.races.create!(category: Category.find_or_create_by_normalized_name("Masters Men"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Masters Men 4/5"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Masters Women"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Masters Women 4"))
      event.races.create!(category: @senior_men)
      event.races.create!(category: @senior_women)
      event.races.create!(category: Category.find_or_create_by_normalized_name("Singlespeed/Fixed"))
      event.races.create!(category: Category.find_or_create_by_normalized_name("Tandem"))

      assert_best_match_in [@senior_men, men_15_24], @senior_men, event
      assert_best_match_in [@junior_women, junior_women_10_12], @junior_women, event
    end

    def assert_best_match_in(categories, race_category, event, result_age = nil)
      categories.each do |category|
        best_match = category.best_match_in(event.categories, result_age)
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
