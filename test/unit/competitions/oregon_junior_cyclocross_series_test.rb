require File.expand_path("../../../test_helper", __FILE__)

class OregonJuniorCyclocrossSeriesTest < ActiveSupport::TestCase
  def test_create
    OregonJuniorCyclocrossSeries.create!
  end
  
  def test_calculate
    series = OregonJuniorCyclocrossSeries.create!(:date => Date.new(2004))
    event = SingleDayEvent.create!(:date => Date.new(2004))
    boys_10_12 = Category.find_or_create_by_name("Boys 10-12")
    event.races.create!(:category => boys_10_12).results.create!(:place => 3, :person => people(:weaver))
    series.source_events << event
    
    OregonJuniorCyclocrossSeries.calculate!
  end
end
