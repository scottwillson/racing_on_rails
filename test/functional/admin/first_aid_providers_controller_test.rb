# :stopdoc:
require "test_helper"

class Admin::FirstAidProvidersControllerTest < ActionController::TestCase
  def setup
    super
    @request.session[:user_id] = users(:administrator).id
  end

  def test_index
    get(:index)
    assert_response(:success)
    assert_template("admin/first_aid_providers/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_equal(false, assigns["past_events"], "past_events")
    assert_equal("date", assigns["sort_by"], "@sort_by default")
  end

  def test_first_aid_update_options
    get(:index, :past_events => true)
    assert_response(:success)
    assert_template("admin/first_aid_providers/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_equal(true, assigns["past_events"], "past_events")
  end

  def test_index_sorting
    get(:index, :sort_by => "promoter_name", :sort_direction => "desc")
    assert_response(:success)
    assert_template("admin/first_aid_providers/index")
    assert_not_nil(assigns["events"], "Should assign events")
    assert_not_nil(assigns["year"], "Should assign year")
    assert_equal(false, assigns["past_events"], "past_events")
    assert_equal("promoter_name", assigns["sort_by"], "@sort_by from param")
  end
end