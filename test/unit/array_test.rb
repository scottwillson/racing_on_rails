require File.dirname(__FILE__) + '/../test_helper'

class ArrayTest < Test::Unit::TestCase
  def test_each_row_with_index
    assert_equal([[], 0], [].each_row_with_index {|row, index|}, 'rows with index')
    assert_equal([[[1]], 0], [1].each_row_with_index {|row, index|}, 'rows with index')
    assert_equal([[[1, 2]], 0], [1, 2].each_row_with_index {|row, index|}, 'rows with index')
    assert_equal([[[1, 3], [2]], 1], [1, 2, 3].each_row_with_index {|row, index|}, 'rows with index')
    assert_equal([[[1, 3], [2, 4]], 1], [1, 2, 3, 4].each_row_with_index {|row, index|}, 'rows with index')
    assert_equal([[[1, 4], [2, 5], [3, 6]], 2], [1, 2, 3, 4, 5, 6].each_row_with_index {|row, index|}, 'rows with index')
  end
end
