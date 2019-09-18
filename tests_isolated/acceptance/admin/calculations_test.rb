# frozen_string_literal: true

require_relative "../acceptance_test"

# :stopdoc:
class Admin::CategoriesTest < AcceptanceTest
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
