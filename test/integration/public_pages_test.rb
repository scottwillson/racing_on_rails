require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PublicPagesTest < ActionController::IntegrationTest
  def test_popular_pages
    get "/events/"
    assert_redirected_to schedule_url
  end
  
  def test_results_pages
    Ironman.calculate! 2004
    event = Ironman.find_for_year(2004)
    result = event.races.first.results.first
    get "/events/#{result.event.to_param}/people/#{result.person.to_param}/results"
    assert_response :success
    assert_select "a", result.name
    assert_select "h2", result.name
    
    get "/events/#{result.event.to_param}/teams/#{result.team.to_param}/results/#{result.race.to_param}"
    assert_response :success
    assert_select "a", result.team_name
    assert_select "h2", result.team_name
    
    result = results(:tonkin_banana_belt)
    get "/events/#{result.event.to_param}"
    assert_response :success
    assert_select "a", result.last_name
    assert_select "h2", result.event.full_name

    get "/events/#{result.event.to_param}/results"
    assert_response :success
    assert_select "a", result.last_name
    assert_select "h2", result.event.full_name
    
    get "/people/#{result.person.to_param}"
    assert_response :success
    assert_select "title", /Results: #{result.name}/
    
    get "/people/#{result.person.to_param}/results"
    assert_response :success
    assert_select "title", /Results: #{result.name}/
    
    get "/teams/#{result.team.to_param}"
    assert_response :success
    assert_select "title", /Results: #{result.team_name}/
    
    get "/teams/#{result.team.to_param}/results"
    assert_response :success
    assert_select "title", /Results: #{result.team_name}/
  end
  
  def test_first_aid_providers
    https! if RacingAssociation.current.ssl?

    get "/admin/first_aid_providers"
    assert_redirected_to(new_person_session_url(secure_redirect_options))

    go_to_login
    login :person_session => { :login => "alice", :password => "secret" }
    get "/admin/first_aid_providers"
    assert_response :success
  end

  private
  
  def go_to_login
    https! if RacingAssociation.current.ssl?
    get new_person_session_path
    assert_response :success
    assert_template "person_sessions/new"
  end

  def login(options)
    https! if RacingAssociation.current.ssl?
    post person_session_path, options
    assert_response :redirect
  end
end
