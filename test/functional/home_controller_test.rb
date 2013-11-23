require_relative "../test_helper"

# :stopdoc:
class HomeControllerTest < ActionController::TestCase
  test "index" do
    FactoryGirl.create(:event, :date => 1.day.from_now)
    future_national_federation_event = FactoryGirl.create(:event, :sanctioned_by => "USA Cycling")
    get :index
    assert_response :success
    assert_not_nil assigns["upcoming_events"], "@upcoming_events"
    assert_not_nil assigns["events_with_recent_results"], "@events_with_recent_results"
    assert_nil assigns["most_recent_event_with_recent_result"], "@most_recent_event_with_recent_result"
    assert_nil assigns["news_category"], "@news_category"
    assert_nil assigns["recent_news"], "@recent_news"
  end
  
  test "edit" do
    use_ssl
    login_as :administrator
    get :edit
    assert_response :success
  end
  
  test "edit should require administrator" do
    use_ssl
    get :edit
    assert_redirected_to new_person_session_path
  end
  
  test "update" do
    use_ssl
    login_as :administrator
    put :update, :home => { :weeks_of_recent_results => 1 }
    assert_redirected_to edit_home_path
  end
end
