require File.expand_path("../../test_helper", __FILE__)

class BarResultsTest < ActionController::IntegrationTest

  # make sure all discipline pages come up with defaults
  def test_all_disciplines_empty_results
    year = Date.today.year
    for discipline in Discipline.find_all_bar
      get '/bar'
      assert_response(:success, '/bar')
      get url_for(:controller => 'bar', :action => 'show', :year => year, :discipline => discipline)
      case @response.response_code
      when 200
        # pass
      when 302
        get url_for(@response.redirected_to)
        assert_response(:success, "#{discipline.name}: redirect to #{@response.redirected_to} should not cause an error nor another redirect")
      else
        fail("Expected success or redirect for #{discipline.name}, but was #{@response.response_code}")
      end
    end
  end
end
