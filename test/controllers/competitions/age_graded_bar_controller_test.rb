require "test_helper"

module Competitions
  # :stopdoc:
  class AgeGradedBarControllerTest < ActionController::TestCase
    tests BarController

    def setup
      super
      age_graded = FactoryBot.create(:discipline, name: "Age Graded")
      @masters_men = FactoryBot.create(:category, name: "Masters Men")
      masters_30_34 = FactoryBot.create(:category, name: "Masters Men 30-34", ages: 30..34, parent: @masters_men)
      age_graded.bar_categories << masters_30_34

      road = FactoryBot.create(:discipline, name: "Road")
      road.bar_categories << @masters_men

      FactoryBot.create(:discipline, name: "Overall")
      FactoryBot.create(:discipline, name: "Mountain Bike")

      weaver = FactoryBot.create(:person, date_of_birth: 32.years.ago(Time.zone.local(2007)))
      banana_belt = FactoryBot.create(:event, date: Date.new(2007, 3, 20))
      banana_belt_masters_30_34 = banana_belt.races.create! category: masters_30_34
      banana_belt_masters_30_34.results.create! person: weaver, place: "10"

      big_team = Team.create(name: "T" * 60)
      weaver = FactoryBot.create(:person, first_name: "f" * 60, last_name: "T" * 60, team: big_team)
      FactoryBot.create(:race).results.create! person: weaver, team: big_team
      Bar.calculate! 2007
      OverallBar.calculate! 2007
      AgeGradedBar.calculate! 2007
    end

    test "show age graded" do
      get :show, discipline: "age_graded", year: "2007", category: "masters_men_30_34"
      assert_response :success
      assert_template "bar/show"
      assert_not_nil assigns["race"], "Should assign race"
    end

    test "show age graded redirect 2006" do
      get :show, discipline: "age_graded", year: "2006", category: "masters_men_30_34"
      assert_redirected_to "http://#{RacingAssociation.current.static_host}/bar/2006/overall_by_age.html"
    end

    test "show redirect before 2006" do
      get :show, discipline: "overall", year: "2003", category: "masters_men_30_34"
      assert_redirected_to "http://#{RacingAssociation.current.static_host}/bar/2003"
    end

  end
end
