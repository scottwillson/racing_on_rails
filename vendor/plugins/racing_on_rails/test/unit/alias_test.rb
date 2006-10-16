require File.dirname(__FILE__) + '/../test_helper'

class AliasTest < Test::Unit::TestCase
  fixtures :teams, :racers, :aliases, :users, :promoters, :categories, :events, :standings, :races, :results

  def test_new
    weaver = racers(:weaver)
    assert_nil(Alias.find_by_name('Weaver'), 'Weaver should not exist')
    racer_alias = Alias.new(:racer => weaver, :name => 'Weave Dog')
    racer_alias.save!
    assert_equal(racer_alias, Alias.find_by_name(racer_alias.name), 'alias by name')

    vanilla = teams(:vanilla)
    assert_nil(Alias.find_by_name('Vanilla/S&M'), 'Vanilla Bicycles/S&M should not exist')
    team_alias = Alias.new(:team => vanilla, :name => 'Vanilla Bicycles/S&M')
    team_alias.save!
    assert_equal(team_alias, Alias.find_by_name(team_alias.name), 'alias by name')
  end
end
