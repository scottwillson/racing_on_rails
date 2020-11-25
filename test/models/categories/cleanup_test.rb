# frozen_string_literal: true

require "test_helper"

module Categories
  # :stopdoc:
  class CleanupTest < ActiveSupport::TestCase
    test "cleanup!" do
      Category.expects(:destroy_unused!)
      Category.expects(:cleanup_names!)
      Category.cleanup!
    end

    test "in_use?" do
      senior_men = FactoryBot.create(:category, name: "Senior Men")
      men_c = FactoryBot.create(:category, name: "Men C", parent: senior_men)
      discipline_bar_category = FactoryBot.create(:category)
      Discipline.create!(name: "Road", bar: true).bar_categories << discipline_bar_category
      race_category = FactoryBot.create(:race).category
      result_category = FactoryBot.create(:category)
      FactoryBot.create(:result, category: result_category)

      assert senior_men.in_use?, "Category with children is in use"
      assert !men_c.in_use?, "unused category should be in use"
      assert discipline_bar_category.in_use?, "Discipline BAR category should be in use"
      assert race_category.in_use?, "race category"
      assert result_category.in_use?, "Result category should be in use"
    end
  end
end
