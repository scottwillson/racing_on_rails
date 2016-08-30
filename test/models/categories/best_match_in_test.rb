require "test_helper"

module Competitions
  # :stopdoc:
  class CategoriesForTest < ActiveSupport::TestCase
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
      event = FactoryGirl.create(:event)
      event.races.create!(category: @cat_1)
      event.races.create!(category: @cat_2)
      event.races.create!(category: @cat_3)
      event.races.create!(category: @cat_4)

      assert_best_match_in [ @cat_1, @cat_1_2, @cat_1_2_3  ], @cat_1, event
      assert_best_match_in [ @cat_2 ], @cat_2, event
      assert_best_match_in [ @cat_3, @cat_3_4, @junior_men_3_4_5 ], @cat_3, event
      assert_best_match_in [ @cat_4, @cat_4_women, @cat_4_5_women, @masters_men_4_5 ], @cat_4, event
    end

    test "ability + gender" do
      event = FactoryGirl.create(:event)
      event.races.create!(category: @cat_1)
      event.races.create!(category: @cat_2)
      event.races.create!(category: @cat_3)
      event.races.create!(category: @cat_4)
      event.races.create!(category: @cat_4_5_women)

      assert_best_match_in [ @cat_1, @cat_1_2, @cat_1_2_3 ], @cat_1, event
      assert_best_match_in [ @cat_2 ], @cat_2, event
      assert_best_match_in [ @cat_4, @masters_men_4_5 ], @cat_4, event
      assert_best_match_in [ @cat_4_women, @cat_4_5_women ], @cat_4_5_women, event
    end

    test "ages" do
      event = FactoryGirl.create(:event)
      event.races.create!(category: @senior_men)
      event.races.create!(category: @senior_women)
      event.races.create!(category: @cat_3)
      event.races.create!(category: @cat_4)
      event.races.create!(category: @cat_4_women)
      event.races.create!(category: @masters_men)
      event.races.create!(category: @masters_men_4_5)
      event.races.create!(category: @junior_men)
      event.races.create!(category: @junior_women)

      assert_best_match_in [ @senior_men, @cat_1, @cat_1_2, @cat_1_2_3, @pro_1_2, @cat_2, @pro_cat_1, @elite_men, @pro_elite_men ], @senior_men, event
      assert_best_match_in [ @senior_women ], @senior_women, event
      assert_best_match_in [ @cat_3, @cat_3_4 ], @cat_3, event
      assert_best_match_in [ @cat_4 ], @cat_4, event
      assert_best_match_in [ @cat_4_women, @cat_4_5_women ], @cat_4_women, event
      assert_best_match_in [ @masters_men ], @masters_men, event
      assert_best_match_in [ @masters_men_4_5, @masters_novice ], @masters_men_4_5, event
      assert_best_match_in [ @junior_men, @junior_men_10_14, @junior_men_15_plus, @junior_men_3_4_5 ], @junior_men, event
      assert_best_match_in [ @junior_women ], @junior_women, event
    end

    test "equipment" do
      event = FactoryGirl.create(:event)
      event.races.create!(category: @singlespeed)
      assert_best_match_in [ @singlespeed, @singlespeed_men, @singlespeed_women ], @singlespeed, event
    end

    test "equipment + gender" do
      event = FactoryGirl.create(:event)
      event.races.create!(category: @singlespeed_men)
      event.races.create!(category: @singlespeed_women)

      assert_best_match_in [ @singlespeed_men, @singlespeed ], @singlespeed_men, event
      assert_best_match_in [ @singlespeed_women ], @singlespeed_women, event
    end

    def assert_best_match_in(categories, race_category, event)
      categories.each do |category|
        assert_equal race_category, category.best_match_in(event), "#{race_category.name} should be best_match_in for #{category.name} in event with categories #{event.races.map(&:name).join(', ')}"
      end

      ::Category.where.not(id: categories).each do |category|
        assert race_category != category.best_match_in(event), "#{race_category.name} should not be best_match_in for #{category.name} in event with categories #{event.races.map(&:name).join(', ')}"
      end
    end
  end
end
