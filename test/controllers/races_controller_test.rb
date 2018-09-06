# frozen_string_literal: true

require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class RacesControllerTest < ActionController::TestCase
  test "index" do
    race = FactoryBot.create(:race)
    get :index, params: { category_id: race.category.to_param.to_s }
    assert_response(:success)
    assert_template("races/index")
    assert_not_nil(assigns["category"], "Should assign category")
  end

  test "event index" do
    race = FactoryBot.create(:race)
    get :index, params: { event_id: race.event.to_param.to_s }
    assert_redirected_to event_results_path(race.event)
  end

  test "show" do
    race = FactoryBot.create(:race)
    get :show, params: { id: race.to_param.to_s }
    assert_redirected_to event_results_path(race.event)
  end
end
