# frozen_string_literal: true

require "test_helper"

# :stopdoc:
class ResultSourceTest < ActiveSupport::TestCase
  test "#<=>" do
    x = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    y = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    assert_equal 0, x <=> y
    assert_equal 0, y <=> x

    x = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    y = ResultSource.new(id: nil, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    assert_equal 0, x <=> y
    assert_equal 0, y <=> x

    x = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    y = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 9, date: Time.zone.today), source_result_id: 9)
    assert_equal 0, x <=> y
    assert_equal 0, y <=> x

    x = ResultSource.new(id: 0, points: 0, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    y = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    assert_equal 1, x <=> y
    assert_equal(-1, y <=> x)
  end

  test "comparison" do
    x = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    y = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    assert_equal [], [x] - [y]
    assert_equal [], [y] - [x]

    x = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    y = ResultSource.new(id: nil, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    assert_equal [], [x] - [y]
    assert_equal [], [y] - [x]

    x = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    y = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 9, date: Time.zone.today), source_result_id: 9)
    assert_equal [x], [x] - [y]
    assert_equal [y], [y] - [x]

    x = ResultSource.new(id: 0, points: 1, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    y = ResultSource.new(id: 0, points: 400, source_result: Result.new(id: 0, date: Time.zone.today), source_result_id: 0)
    assert_equal [x], [x] - [y]
    assert_equal [y], [y] - [x]
  end
end
