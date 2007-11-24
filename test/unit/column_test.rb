require File.dirname(__FILE__) + '/../test_helper'

class ColumnTest < ActiveSupport::TestCase
  
  def test_create
    column = Column.new(:name => "place")
    assert_equal("place", column.name, "Name after create")
    assert_equal(:place, column.field, "Field after create")
  end
end
