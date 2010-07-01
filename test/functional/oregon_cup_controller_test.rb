require File.expand_path("../../test_helper", __FILE__)

class OregonCupControllerTest < ActionController::TestCase
  def test_index
    OregonCup.create(:date => Date.new(2004))
    get(:index, :year => "2004")
    assert_response(:success)
    assert_template("oregon_cup/index")
    assert_not_nil(assigns["oregon_cup"], "Should assign oregon_cup")
  end

  def test_index_without_event
    get(:index, :year => "2004")
    assert_response(:success)
    assert_template("oregon_cup/index")
    assert_not_nil(assigns["oregon_cup"], "Should assign oregon_cup")
  end
end
