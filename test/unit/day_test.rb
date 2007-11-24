require File.dirname(__FILE__) + '/../test_helper'
require 'schedule/month'
require 'schedule/day'

class DayTest < ActiveSupport::TestCase
  def test_other_month
    month = Schedule::Month.new(2007, 1)
    
    date = Date.new(2006, 12, 31)
    day = Schedule::Day.new(month, date)
    assert(day.other_month?, "#{date.to_s(:short)} should be in other month for month #{month}")
    
    date = Date.new(2007, 1, 1)
    day = Schedule::Day.new(month, date)
    assert(!day.other_month?, "#{date.to_s(:short)} should not be in other month for month #{month}")
    
    date = Date.new(2007, 2, 1)
    day = Schedule::Day.new(month, date)
    assert(day.other_month?, "#{date.to_s(:short)} should be in other month for month #{month}")
  end
end
