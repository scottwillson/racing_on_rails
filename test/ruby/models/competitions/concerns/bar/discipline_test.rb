require File.expand_path("../../../../../test_case", __FILE__)
require File.expand_path("../../../../../../../app/models/competitions/concerns/bar/discipline", __FILE__)

# :stopdoc:
# Used to only award bonus points for races of five or less, but now all races get equal points
class Concerns::Bar::DisciplineTest < Ruby::TestCase
  def setup
    @bar = Object.new
    @bar.extend Concerns::Bar::Discipline
  end

  test "discipline_for_road_race" do
    race = stub("race", discipline: "Road")
    assert_equal_enumerables [ "Road", "Circuit" ], @bar.disciplines_for(race), "disciplines"
  end

  test "discipline_for_track" do
    race = stub("race", discipline: "Track")
    assert_equal_enumerables [ "Track" ], @bar.disciplines_for(race), "disciplines"
  end

  test "discipline_for_mtb" do
    race = stub("race", discipline: "Mountain Bike")
    assert_equal_enumerables [ "Mountain Bike", "Downhill", "Super D" ], @bar.disciplines_for(race), "disciplines"
  end

  test "discipline_for_dh" do
    race = stub("race", discipline: "Downhill")
    assert_equal_enumerables [ "Downhill" ], @bar.disciplines_for(race), "disciplines"
  end
end
