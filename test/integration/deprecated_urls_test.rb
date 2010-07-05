require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class DeprecatedURLsTest < ActionController::IntegrationTest
  def test_event_results
    event = events(:pir)
    get "/results/event/#{event.id}"
    assert_redirected_to "/events/#{event.id}/results"
    assert_response :moved_permanently

    get "/events/#{event.id}/results"
    assert_response :success
    assert_template "results/event"

    get "/events/#{event.id}"
    assert_response :success
    assert_template "results/event"
    
    get "/results/2009/Time Trial/#{event.id}"
    assert_redirected_to "/events/#{event.id}/results"
    assert_response :moved_permanently
    
    get "/results/2009/time_trial/#{event.id}"
    assert_redirected_to "/events/#{event.id}/results"
    assert_response :moved_permanently
    
    get "/results/2009/Mountain%20Bike/#{event.id}"
    assert_redirected_to "/events/#{event.id}/results"
    assert_response :moved_permanently
    
    get "/results/2009/road/#{event.id}"
    assert_redirected_to "/events/#{event.id}/results"
    assert_response :moved_permanently
    
    get "/results/2009/Road/#{event.id}"
    assert_redirected_to "/events/#{event.id}/results"
    assert_response :moved_permanently
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
  
  def test_results
    result = results(:tonkin_banana_belt)
    get "/results/show/#{result.id}"
    assert_redirected_to "/events/#{result.event.id}/people/#{people(:tonkin).id}/results"
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
    assert_template "results/team"

    get "/teams/#{team.id}"
    assert_response :success
    assert_template "results/team"
  end
end
