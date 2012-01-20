require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ResultsHelperTest < ActionView::TestCase
  def test_link_to_team_results
    senior_men = FactoryGirl.create(:category)
    result = Event.new.races.build(:category => senior_men).results.new
    assert_nil link_to_team_results(nil, result), "Result with no text, no team"
    assert_equal "", link_to_team_results("", result), "Result with no text, no team"

    team = FactoryGirl.create(:team)
    result = Event.new.races.build(:category => senior_men).results.new(:team => team)

    # Unrealistic
    assert_match(/\/teams\/#{team.id}/, link_to_team_results("", result), "Result with no text, team")

    assert_match(/\/teams\/#{team.id}/, link_to_team_results("GL", result), "Result with no text, team")
  end
  
  def test_link_to_team_competition_result
    senior_men = FactoryGirl.create(:category)
    result = MbraBar.new.races.build(:category => senior_men).results.new
    assert_nil link_to_team_results(nil, result), "Result with no text, no team"
    assert_equal "", link_to_team_results("", result), "Result with no text, no team"

    team = FactoryGirl.create(:team)
    result = Event.new.races.build(:category => senior_men).results.new(:team => team)

    # Unrealistic
    assert_match(/\/teams\/#{team.id}/, link_to_team_results("", result), "Result with no text, team")
    assert_match(/\/teams\/#{team.id}/, link_to_team_results("GL", result), "Result with no text, team")
  end  
end
