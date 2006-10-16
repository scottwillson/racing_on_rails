require File.dirname(__FILE__) + '/../test_helper'

class SeriesTest < Test::Unit::TestCase
  
  fixtures :events, :standings, :races

  def test_new
    series = Series.new
    series.save!
  end
  
end