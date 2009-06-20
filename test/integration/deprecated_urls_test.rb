require "test_helper"

# TODO redirect from showing all BAR results (and fix links)
class DeprecatedURLsTest < ActionController::IntegrationTest
  setup :activate_authlogic
  
  def test_event_results
    event = events(:pir)
    get "/results/2004/road/#{event.id}"
    assert_redirected_to "/events/#{event.id}/results"
    assert_response :moved_permanently
    
    get "/results/event/#{event.id}"
    assert_redirected_to "/events/#{event.id}/results"
    assert_response :moved_permanently

    get "/events/#{event.id}/results"
    assert_response :success
    assert_template "results/event"
  end

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
  
  def test_redirect_team_results
    RiderRankings.calculate!
    competition = RiderRankings.find_for_year
    team = teams(:vanilla)
    get "/results/competition/#{competition.id}/team/#{team.id}"
    assert_redirected_to "/events/#{competition.id}/teams/#{team.id}/results"
    assert_response :moved_permanently
    
    get "/results/team/#{team.id}"
    assert_redirected_to "/teams/#{team.id}/results"
    assert_response :moved_permanently

    get "/teams/#{team.id}/results"
    assert_response :success
    assert_template "teams/show"

    get "/teams/#{team.id}"
    assert_response :success
    assert_template "teams/show"
  end
  
  def test_admin_racers
    post person_session_path, :person_session => { :login => 'admin@example.com', :password => 'secret' }
    assert_response :redirect
    
    get "/admin/racers"
    assert_redirected_to "/admin/people"
    assert_response :moved_permanently
  end
end
