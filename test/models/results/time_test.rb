# frozen_string_literal: true

require File.expand_path("../../test_helper", __dir__)

# :stopdoc:
class ResultTest < ActiveSupport::TestCase
  setup :number_issuer

  def number_issuer
    FactoryBot.create(:number_issuer)
    FactoryBot.create(:discipline)
  end

  test "set time" do
    result = Result.new
    result.time = "20:23:00.9"
    assert_in_delta 73_380.9, result.time, 0.0001, "20:23:00.9 should be 20 hours and 23 minutes and 0.9 seconds"

    result.time = "20:23:00"
    assert_in_delta 73_380.0, result.time, 0.0001, "20:23:00 should be 20 hours and 23 minutes"

    result.time = "20:23.00"
    assert_in_delta 1223.0, result.time, 0.0001, "20:23.00 should be 20 minutes and 23 seconds"

    result.time = "20:23"
    assert_in_delta 1223.0, result.time, 0.0001, "20:23 should be 20 minutes and 23 seconds"

    result.time = "20:23.0001"
    assert_equal 1223, result.time, "time should round to thousandths"

    result.time = "20:23.0009"
    assert_equal 1223.001, result.time, "time should round to thousandths"

    result.time = "DNS"
    assert_nil result.time, "bogus times should be nil"
  end

  test "time s" do
    result = Result.new
    assert_nil result.time, "no time"
    assert_equal "", result.time_s, "no time_s"
    result.time_s = ""
    assert_nil result.time, "bogus times should be nil"

    result.time = 2597.0
    assert_in_delta(2597.0, result.time, 0.0001, "time")
    assert_equal("43:17.00", result.time_s, "time_s")
    result.time_s = "43:17.00"
    assert_in_delta(2597.0, result.time, 0.0001, "time")

    result.time_s = "30:00"
    assert_in_delta(1800.0, result.time, 0.0001, "time")
    assert_equal("30:00.00", result.time_s, "time_s")
    assert_in_delta(1800.0, result.time, 0.0001, "time")

    result.time_s = ":00:30:00.1"
    assert_in_delta(1800.1, result.time, 0.0001, "time")
    assert_equal("30:00.10", result.time_s, "time_s")

    result.time = 3609.0
    assert_in_delta(3609.0, result.time, 0.0001, "time")
    assert_equal("01:00:09.00", result.time_s, "time_s")
    result.time_s = "01:00:09"
    assert_in_delta(3609.0, result.time, 0.0001, "time")

    result.time_s = "1:59:59"
    assert_in_delta(7199.0, result.time, 0.0001, "time")
    assert_equal("01:59:59.00", result.time_s, "time_s")
    result.time_s = "01:59:59"
    assert_in_delta(7199.0, result.time, 0.0001, "time")

    result.time = 2252.0
    assert_in_delta(2252.0, result.time, 0.0001, "time")
    assert_equal("37:32.00", result.time_s, "time_s")
    result.time_s = "37:32"
    assert_in_delta(2252.0, result.time, 0.0001, "time")

    result.time = 2449.0
    assert_in_delta(2449.0, result.time, 0.0001, "time")
    assert_equal("40:49.00", result.time_s, "time_s")
    result.time_s = "40:49"
    assert_in_delta(2449.0, result.time, 0.0001, "time")

    result.time = 1530.29
    assert_in_delta(1530.29, result.time, 0.0001, "time")
    assert_equal("25:30.29", result.time_s, "time_s")
    result.time_s = "25:30.29"
    assert_in_delta(1530.29, result.time, 0.0001, "time")

    result.time = 1567.98
    assert_in_delta(1567.98, result.time, 0.0001, "time")
    assert_equal("26:07.98", result.time_s, "time_s")
    result.time_s = "26:07.98"
    assert_in_delta(1567.98, result.time, 0.0001, "time")

    # Other times
    result.time_bonus_penalty = 10.0
    assert_in_delta(10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
    assert_equal("00:10.00", result.time_bonus_penalty_s, "time_bonus_penalty_s")
    result.time_bonus_penalty_s = "0:00:10"
    assert_in_delta(10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")

    result.time_bonus_penalty = 90.0
    assert_in_delta(90.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
    assert_equal("01:30.00", result.time_bonus_penalty_s, "time_bonus_penalty_s")
    result.time_bonus_penalty_s = "0:01:30"
    assert_in_delta(90.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")

    result.time_total = 12_798.0
    assert_in_delta(12_798.0, result.time_total, 0.0001, "time_total")
    assert_equal("03:33:18.00", result.time_total_s, "time_total_s")
    result.time_total_s = "3:33:18.00"
    assert_in_delta(12_798.0, result.time_total, 0.0001, "time_total")

    result.time_gap_to_leader = 74.0
    assert_in_delta(74.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")
    assert_equal("01:14.00", result.time_gap_to_leader_s, "time_gap_to_leader_s")
    result.time_gap_to_leader_s = "0:01:14"
    assert_in_delta(74.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")

    result.time_gap_to_leader = 0.0
    assert_in_delta(0.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")
    assert_equal("", result.time_gap_to_leader_s, "time_gap_to_leader_s")
    result.time_gap_to_leader_s = "0:00:00"
    assert_in_delta(0.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")

    result.time_bonus_penalty = -10.0
    assert_in_delta(-10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
    assert_equal("-00:10.00", result.time_bonus_penalty_s, "time_bonus_penalty_s")
    result.time_bonus_penalty_s = "-0:00:10"
    assert_in_delta(-10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
  end

  test "time_value" do
    result = Result.new
    time = Time.zone.local(2007, 11, 20, 19, 45, 50, 678)
    assert_equal(71_156.78, result.time_value(time))

    result = Result.new
    time = DateTime.new(2007, 11, 20, 19, 45, 50)
    assert_equal(71_150.0, result.time_value(time))

    # this was an old Excel/parser edge case
    result = Result.new
    time = DateTime.new(1899, 12, 31, 1, 39, 19)
    assert_equal(5_959.0, result.time_value(time))
  end
end
