require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class CrossCrusadeCallupsTest < ActiveSupport::TestCase  
  def test_calculate
    series = CrossCrusadeCallups.create!
    event = SingleDayEvent.create!
    series.source_events << event
    event.races.create!(:category => categories(:senior_men)).results.create!(:place => "1", :person => people(:member))
    CrossCrusadeCallups.calculate!
  end
end