require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class RacesControllerTest < ActionController::TestCase
  def test_index
    get(:index, :category_id => "#{categories(:sr_p_1_2).to_param}")
    assert_response(:success)
    assert_template("races/index")
    assert_not_nil(assigns["category"], "Should assign category")
  end
end