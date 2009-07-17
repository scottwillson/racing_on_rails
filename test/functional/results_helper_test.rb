require "test_helper"

# :stopdoc:
class ResultsHelperTest < ActionView::TestCase
  def test_link_to_team_result
    result = Event.new.races.build(:category => categories(:senior_men)).results.new
    assert_nil link_to_team_result(nil, result), "Result with no text, no team"
    assert_equal "", link_to_team_result("", result), "Result with no text, no team"

    team = teams(:vanilla)
    result = Event.new.races.build(:category => categories(:senior_men)).results.new(:team => team)

    # Unrealistic
    assert_match(/\/teams\/#{team.id}/, link_to_team_result("", result), "Result with no text, team")

    assert_match(/\/teams\/#{team.id}/, link_to_team_result("GL", result), "Result with no text, team")
  end
  
  def test_link_to_team_competition_result
    result = MbraBar.new.races.build(:category => categories(:senior_men)).results.new
    assert_nil link_to_team_result(nil, result), "Result with no text, no team"
    assert_equal "", link_to_team_result("", result), "Result with no text, no team"

    team = teams(:vanilla)
    result = Event.new.races.build(:category => categories(:senior_men)).results.new(:team => team)

    # Unrealistic
    assert_match(/\/teams\/#{team.id}/, link_to_team_result("", result), "Result with no text, team")

    assert_match(/\/teams\/#{team.id}/, link_to_team_result("GL", result), "Result with no text, team")
  end  
end
