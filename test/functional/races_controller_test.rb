require File.dirname(__FILE__) + '/../test_helper'
require_or_load 'races_controller'

class RacesController; def rescue_action(e) raise e end; end

class RacesControllerTest < Test::Unit::TestCase

  def setup
    @controller = RacesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_category
    opts = {:controller => "races", :action => "category", :id => categories(:sr_p_1_2).to_param.to_s}
    assert_routing("/races/category/#{categories(:sr_p_1_2).to_param}", opts)
    get(:category, :id => "#{categories(:sr_p_1_2).to_param}")
    assert_response(:success)
    assert_template("races/category")
    assert_not_nil(assigns["category"], "Should assign category")
  end
end