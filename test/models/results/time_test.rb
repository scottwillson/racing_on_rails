require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class ResultTest < ActiveSupport::TestCase
  setup :number_issuer
  
  def number_issuer
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline)
  end
  
  def test_set_time
    result = Result.new
    result.time = "20:23:00.9"
    assert_in_delta 73380.9, result.time, 0.0001, "20:23:00.9 should be 20 hours and 23 minutes and 0.9 seconds"

    result.time = "20:23:00"
    assert_in_delta 73380.0, result.time, 0.0001, "20:23:00 should be 20 hours and 23 minutes"

    result.time = "20:23.00"
    assert_in_delta 1223.0, result.time, 0.0001, "20:23.00 should be 20 minutes and 23 seconds"

    result.time = "20:23"
    assert_in_delta 1223.0, result.time, 0.0001, "20:23 should be 20 minutes and 23 seconds"
  end

  def test_time_s
    result = Result.new
    assert_equal nil, result.time, "no time"
    assert_equal '', result.time_s, 'no time_s'
    result.time_s = ''
    assert_in_delta 0.0, result.time, 0.0001, "no time"
    
    result.time = 2597.0
    assert_in_delta(2597.0, result.time, 0.0001, "time")
    assert_equal('43:17.00', result.time_s, 'time_s')
    result.time_s = '43:17.00'
    assert_in_delta(2597.0, result.time, 0.0001, "time")
    
    result.time_s = '30:00'
    assert_in_delta(1800.0, result.time, 0.0001, "time")
    assert_equal('30:00.00', result.time_s, 'time_s')
    assert_in_delta(1800.0, result.time, 0.0001, "time")
    
    result.time_s = ':00:30:00.1'
    assert_in_delta(1800.1, result.time, 0.0001, "time")
    assert_equal('30:00.10', result.time_s, 'time_s')
    
    result.time = 3609.0
    assert_in_delta(3609.0, result.time, 0.0001, "time")
    assert_equal('01:00:09.00', result.time_s, 'time_s')
    result.time_s = '01:00:09'
    assert_in_delta(3609.0, result.time, 0.0001, "time")
    
    result.time_s = '1:59:59'
    assert_in_delta(7199.0, result.time, 0.0001, "time")
    assert_equal('01:59:59.00', result.time_s, 'time_s')
    result.time_s = '01:59:59'
    assert_in_delta(7199.0, result.time, 0.0001, "time")
    
    result.time = 2252.0
    assert_in_delta(2252.0, result.time, 0.0001, "time")
    assert_equal('37:32.00', result.time_s, 'time_s')
    result.time_s = '37:32'
    assert_in_delta(2252.0, result.time, 0.0001, "time")
    
    result.time = 2449.0
    assert_in_delta(2449.0, result.time, 0.0001, "time")
    assert_equal('40:49.00', result.time_s, 'time_s')
    result.time_s = '40:49'
    assert_in_delta(2449.0, result.time, 0.0001, "time")
    
    result.time = 1530.29
    assert_in_delta(1530.29, result.time, 0.0001, "time")
    assert_equal('25:30.29', result.time_s, 'time_s')
    result.time_s = '25:30.29'
    assert_in_delta(1530.29, result.time, 0.0001, "time")
    
    result.time = 1567.98
    assert_in_delta(1567.98, result.time, 0.0001, "time")
    assert_equal('26:07.98', result.time_s, 'time_s')
    result.time_s = '26:07.98'
    assert_in_delta(1567.98, result.time, 0.0001, "time")
    
    # Other times
    result.time_bonus_penalty = 10.0
    assert_in_delta(10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
    assert_equal('00:10.00', result.time_bonus_penalty_s, 'time_bonus_penalty_s')
    result.time_bonus_penalty_s = '0:00:10'
    assert_in_delta(10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
    
    result.time_bonus_penalty = 90.0
    assert_in_delta(90.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
    assert_equal('01:30.00', result.time_bonus_penalty_s, 'time_bonus_penalty_s')
    result.time_bonus_penalty_s = '0:01:30'
    assert_in_delta(90.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
    
    result.time_total = 12798.0
    assert_in_delta(12798.0, result.time_total, 0.0001, "time_total")
    assert_equal('03:33:18.00', result.time_total_s, 'time_total_s')
    result.time_total_s = '3:33:18.00'
    assert_in_delta(12798.0, result.time_total, 0.0001, "time_total")
    
    result.time_gap_to_leader = 74.0
    assert_in_delta(74.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")
    assert_equal('01:14.00', result.time_gap_to_leader_s, 'time_gap_to_leader_s')
    result.time_gap_to_leader_s = '0:01:14'
    assert_in_delta(74.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")
    
    result.time_gap_to_leader = 0.0
    assert_in_delta(0.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")
    assert_equal('', result.time_gap_to_leader_s, 'time_gap_to_leader_s')
    result.time_gap_to_leader_s = '0:00:00'
    assert_in_delta(0.0, result.time_gap_to_leader, 0.0001, "time_gap_to_leader")
    
    result.time_bonus_penalty = -10.0
    assert_in_delta(-10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
    assert_equal('-00:10.00', result.time_bonus_penalty_s, 'time_bonus_penalty_s')
    result.time_bonus_penalty_s = '-0:00:10'
    assert_in_delta(-10.0, result.time_bonus_penalty, 0.0001, "time_bonus_penalty")
  end
  
  def test_set_time_value
    result = Result.new
    time = Time.zone.local(2007, 11, 20, 19, 45, 50, 678)
    result.set_time_value(:time, time)
    assert_equal(71156.78, result.time)

    result = Result.new
    time = DateTime.new(2007, 11, 20, 19, 45, 50)
    result.set_time_value(:time, time)
    assert_equal(71150.0, result.time)
  end
  
end
