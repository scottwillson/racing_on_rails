require File.dirname(__FILE__) + '/../test_helper'

class SeriesTest < ActiveSupport::TestCase
  
  def test_new
    series = Series.new
    series.save!
  end
end