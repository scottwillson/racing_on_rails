require File.expand_path("../../../../test_case", __FILE__)
require File.expand_path("../../../../../../lib/racing_on_rails/grid/column", __FILE__)

# :stopdoc:
module RacingOnRails
  module Grid
    class ColumnTest < Ruby::TestCase
      def test_create
        column = Column.new(:name => "place")
        assert_equal("place", column.name, "Name after create")
        assert_equal(:place, column.field, "Field after create")
      end
    end
  end
end
