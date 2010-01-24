require "test_helper"

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
    
    get "/events/#{result.event.to_param}/teams/#{result.team.to_param}/results"
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
    assert_select "title", /#{ASSOCIATION.short_name}(.*)Results: #{result.name}/
    
    get "/people/#{result.person.to_param}/results"
    assert_response :success
    assert_select "title", /#{ASSOCIATION.short_name}(.*)Results: #{result.name}/
    
    get "/teams/#{result.team.to_param}"
    assert_response :success
    assert_select "title", /#{ASSOCIATION.short_name}(.*)Results: #{result.team_name}/
    
    get "/teams/#{result.team.to_param}/results"
    assert_response :success
    assert_select "title", /#{ASSOCIATION.short_name}(.*)Results: #{result.team_name}/
  end

  private
  
  def go_to_login
    https! if ASSOCIATION.ssl?
    get new_person_session_path
    assert_response :success
    assert_template "person_sessions/new"
  end
  
  def login(options)
    post person_session_path, options
    assert_response :redirect
  end
end
