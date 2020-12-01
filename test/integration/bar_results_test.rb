# frozen_string_literal: true

require_relative "racing_on_rails/integration_test"

# :stopdoc:
class BarResultsTest < RacingOnRails::IntegrationTest
  # make sure all discipline pages come up with defaults
  test "all disciplines empty results" do
    year = Time.zone.today.year
    Discipline.find_all_bar.each do |discipline|
      get "/bar"
      assert_response(:success, "/bar")
      get url_for(controller: "bar", action: "show", year: year, discipline: discipline)
      case @response.response_code
      when 200
        # pass
      when 302
        get url_for(@response.redirected_to)
        assert_response(:success, "#{discipline.name}: redirect to #{@response.redirected_to} should not cause an error nor another redirect")
      else
        raise("Expected success or redirect for #{discipline.name}, but was #{@response.response_code}")
      end
    end
  end
end
