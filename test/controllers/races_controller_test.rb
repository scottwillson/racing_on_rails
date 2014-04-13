require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class RacesControllerTest < ActionController::TestCase
  def test_index
    race = FactoryGirl.create(:race)
    get(:index, :category_id => "#{race.category.to_param}")
    assert_response(:success)
    assert_template("races/index")
    assert_not_nil(assigns["category"], "Should assign category")
  end

  def test_event_index
    race = FactoryGirl.create(:race)
    get(:index, :event_id => "#{race.event.to_param}")
    assert_redirected_to event_results_path(race.event)
  end

  def test_show
    race = FactoryGirl.create(:race)
    get(:show, :id => "#{race.to_param}")
    assert_redirected_to event_results_path(race.event)
  end
end
