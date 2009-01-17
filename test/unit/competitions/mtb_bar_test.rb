require "test_helper"

class MtbBarTest < ActiveSupport::TestCase
  def test_no_masters_or_junior_ability_categories
    expert_junior_men = categories(:expert_junior_men)
    junior_men = categories(:junior_men)
    sport_junior_men = categories(:sport_junior_men)

    marin_knobular = SingleDayEvent.create!(:name => "Marin Knobular", :date => Date.new(2001, 9, 7), :discipline => "Mountain Bike")
    standings = marin_knobular.standings.create
    race = standings.races.create!(:category => expert_junior_men)
    kc = Racer.create!(:name => "KC Mautner", :member_from => Date.new(2001, 1, 1))
    vanilla = teams(:vanilla)
    race.results.create!(:racer => kc, :place => 4, :team => vanilla)
    chris_woods = Racer.create!(:name => "Chris Woods", :member_from => Date.new(2001, 1, 1))
    gentle_lovers = teams(:gentle_lovers)
    race.results.create!(:racer => chris_woods, :place => 12, :team => gentle_lovers)
    
    lemurian = SingleDayEvent.create!(:name => "Lemurian", :date => Date.new(2001, 9, 14), :discipline => "Mountain Bike")
    standings = marin_knobular.standings.create
    race = standings.races.create!(:category => sport_junior_men)
    race.results.create!(:racer => chris_woods, :place => 14, :team => gentle_lovers)

    Bar.recalculate(2001)
    bar = Bar.find(:first, :conditions => ["date = ?", Date.new(2001, 1, 1)])
    assert_not_nil(bar, "2001 BAR after recalculate")
    assert_equal(7, bar.standings.count, "Bar standings after recalculate")

    mtb_bar = bar.standings.detect {|s| s.name == "Mountain Bike" }
    junior_men_mtb_bar = mtb_bar.races.detect {|b| b.name == "Junior Men" }

    assert_equal(2, junior_men_mtb_bar.results.size, "Junior Men BAR results")
    junior_men_mtb_bar.results.sort! {|x, y| x.racer <=> y.racer}
    assert_equal(kc, junior_men_mtb_bar.results.first.racer, "Junior Men BAR first result")
    assert_equal(chris_woods, junior_men_mtb_bar.results.last.racer, "Junior Men BAR last result")
    assert_equal(19, junior_men_mtb_bar.results.first.points, "Junior Men BAR first points")
    assert_equal(6, junior_men_mtb_bar.results.last.points, "Junior Men BAR last points")
    assert_equal(2, junior_men_mtb_bar.results.last.scores.size, "Junior Men BAR last scores")
  end
end