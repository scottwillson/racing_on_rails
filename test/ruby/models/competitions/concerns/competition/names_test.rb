require File.expand_path("../../../../../test_case", __FILE__)
require File.expand_path("../../../../../../../app/models/competitions/concerns/competition/names", __FILE__)

# :stopdoc:
class Concerns::Competition::NamesTest < Ruby::TestCase
  class TestCompetition
    include Concerns::Competition::Names

    def name=(value)
      @name = value
    end

    def [](value)
      @name
    end

    def []=(key, value)
      @name = value
    end
  end

  test "default_name" do
    competition = TestCompetition.new
    assert_equal("Competition", competition.friendly_name, "Default friendly_name")
  end

  test "name_from_friendly_name" do
    competition = TestCompetition.new
    competition.stubs(:friendly_name).returns("KOM")
    assert_equal("KOM", competition.friendly_name, "friendly_name")
  end

  test "name" do
    competition = TestCompetition.new
    competition.stubs(:friendly_name).returns("KOM")
    competition.stubs(:date).returns(Date.new(2008))
    assert_equal("2008 KOM", competition.name, "name")

    competition.name = "QOM"
    assert_equal("QOM", competition.name, "name")
  end
end
