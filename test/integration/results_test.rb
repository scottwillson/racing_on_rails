require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ResultsTest < ActionController::IntegrationTest
  def test_custom_columns
    goto_login_page_and_login_as :administrator

    event = events(:banana_belt_1)
    get edit_admin_event_path(event)
    assert_response :success

    post upload_admin_event_path, :id => event.to_param, :results_file => fixture_file_upload("results/dh.xls", "application/vnd.ms-excel", :binary)
    assert_response :redirect
    follow_redirect!
    assert_response :success
    
    get event_path(event)
    assert_response :success
    
    assert @response.body["Run 1"]
    assert @response.body["Run 2"]
  end
end
