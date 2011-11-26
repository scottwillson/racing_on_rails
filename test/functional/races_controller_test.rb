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
end