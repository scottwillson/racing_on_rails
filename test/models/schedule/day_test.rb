# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

# :stopdoc:
class DayTest < ActiveSupport::TestCase
  test "other month" do
    month = Schedule::Month.new(2007, 1)

    date = Date.new(2006, 12, 31)
    day = Schedule::Day.new(month, date)
    assert(day.other_month?, "#{date.to_s(:mdy)} should be in other month for month #{month}")

    date = Date.new(2007, 1, 1)
    day = Schedule::Day.new(month, date)
    assert_not(day.other_month?, "#{date.to_s(:mdy)} should not be in other month for month #{month}")

    date = Date.new(2007, 2, 1)
    day = Schedule::Day.new(month, date)
    assert(day.other_month?, "#{date.to_s(:mdy)} should be in other month for month #{month}")
  end
end
