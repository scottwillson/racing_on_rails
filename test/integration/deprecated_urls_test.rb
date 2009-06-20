require "test_helper"

class DeprecatedURLsTest < ActionController::IntegrationTest
  setup :activate_authlogic

  def test_redirect_racer_results
    weaver = people(:weaver)
    get "/results/racer/#{weaver.id}"
    assert_redirected_to "/people/#{weaver.id}/results"
    assert_response :moved_permanently
    
    RiderRankings.calculate! 2004
    competition = RiderRankings.find_for_year 2004
    get "/results/competition/#{competition.id}/racer/#{weaver.id}"
    assert_redirected_to "/events/#{competition.id}/people/#{weaver.id}/results"
    assert_response :moved_permanently
  end
  
  def test_admin_racers
    post person_session_path, :person_session => { :login => 'admin@example.com', :password => 'secret' }
    assert_response :redirect
    
    get "/admin/racers"
    assert_redirected_to "/admin/people"
    assert_response :moved_permanently
  end
end
