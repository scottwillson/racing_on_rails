require File.expand_path("../../../test_case", __FILE__)
require File.expand_path("../../../../../lib/grid/column", __FILE__)

module Grid
  # :stopdoc:
  class ColumnTest < Ruby::TestCase
    def test_create
      column = Column.new(name: "place")
      assert_equal("place", column.name, "Name after create")
      assert_equal(:place, column.field, "Field after create")
    end
  end
end
