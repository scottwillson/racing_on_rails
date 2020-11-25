# frozen_string_literal: true

require "application_system_test_case"

# :stopdoc:
class Admin::CategoriesTest < ApplicationSystemTestCase
  test "edit" do
    FactoryBot.create(:discipline)

    Calculations::V3::Calculation.create!(
      members_only: true,
      name: "Ironman",
      points_for_place: 1
    )

    login_as FactoryBot.create(:administrator)

    visit "/calculations"
  end
end
