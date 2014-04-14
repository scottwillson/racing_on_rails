require File.expand_path("../../../test_helper", __FILE__)

module Competitions
  # :stopdoc:
  class OregonCupControllerTest < ActionController::TestCase
    tests OregonCupController

    def test_index
      event = ::OregonCup.create!(date: Date.new(2004, 3, 18))
      race = event.races.create!(category: FactoryGirl.create(:category))
      result = race.results.create!(place: 1, person: Person.create!(name: "Floyd Landis"))

      get :index, year: "2004"
      assert_response :success
      assert_template "oregon_cup/index"
      assert_equal event, assigns["oregon_cup"], "Should assign oregon_cup"
      assert response.body["Floyd Landis"], "Should have results"
    end

    def test_index_without_event
      get(:index, year: "2004")
      assert_response(:success)
      assert_template("oregon_cup/index")
      assert_not_nil(assigns["oregon_cup"], "Should assign oregon_cup")
    end
  end
end
