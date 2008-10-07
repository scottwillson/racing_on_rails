# :stopdoc:
require File.dirname(__FILE__) + '/../../test_helper'

class Admin::FirstAidProvidersControllerTest < ActionController::TestCase
  def setup
    super
    @request.session[:user] = users(:candi)
  end

  def test_index
    get(:index)
    assert_response(:success)
    assert_template("admin/first_aid_providers/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_equal(false, assigns["past_events"], "past_events")
  end

  def test_first_aid_update_options
    get(:index, :past_events => true)
    assert_response(:success)
    assert_template("admin/first_aid_providers/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_equal(true, assigns["past_events"], "past_events")
  end
end