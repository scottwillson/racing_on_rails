require_relative "../../../test_case"
require "tabular"
require_relative "../../../../../app/helpers/results/renderers/time_renderer"

module Results
  module Renderers
    # :stopdoc:
    class TimeRendererTest < Ruby::TestCase
      def test_render_nil
        row = Tabular::Table.new([{time: nil}]).rows.first
        column = stub("column", key: :time, precision: 0, cells: [])
        assert_equal nil, TimeRenderer.render(column, row)
      end

      def test_render_zero
        row = stub("row", "[]" => 0)
        column = stub("column", key: :time, precision: 0, cells: [ 7200 ])
        assert_equal "0:00:00", TimeRenderer.render(column, row)

        column = stub("column", key: :time, precision: 0, cells: [ 3600 ])
        assert_equal "0:00:00", TimeRenderer.render(column, row)

        column = stub("column", key: :time, precision: 0, cells: [ 3599 ])
        assert_equal "00:00", TimeRenderer.render(column, row)

        column = stub("column", key: :time, precision: 0, cells: [ 1200, "..." ])
        assert_equal "00:00", TimeRenderer.render(column, row)
      end

      def test_render_minute
        row = stub("row", "[]" => 61)
        column = stub("column", key: :time, precision: 0, cells: [ 9000 ])
        assert_equal "0:01:01", TimeRenderer.render(column, row)

        row = stub("row", "[]" => 60)
        assert_equal "0:01:00", TimeRenderer.render(column, row)

        row = stub("row", "[]" => 59)
        assert_equal "0:00:59", TimeRenderer.render(column, row)
      end

      def test_render_25_hours
        row = stub("row", "[]" => 60 * 60 * 25)
        column = stub("column", key: :time, precision: 0, cells: [ 9000 ])
        assert_equal "25:00:00", TimeRenderer.render(column, row)
      end

      def test_render_decimals
        row = stub("row", "[]" => 12.99)
        column = stub("column", key: :time, precision: 2, cells: [ 9000 ])
        assert_equal "0:00:12.99", TimeRenderer.render(column, row)
      end

      def test_render_with_precision
        row = stub("row", "[]" => 12)
        column = stub("column", key: :time, precision: 0, cells: [ 9000 ])
        assert_equal "0:00:12", TimeRenderer.render(column, row)

        row = stub("row", "[]" => 12)
        column = stub("column", key: :time, cells: [ 9000 ], precision: 1)
        assert_equal "0:00:12.0", TimeRenderer.render(column, row)

        row = stub("row", "[]" => 12)
        column = stub("column", key: :time, cells: [ 9000 ], precision: 2)
        assert_equal "0:00:12.00", TimeRenderer.render(column, row)

        row = stub("row", "[]" => 12)
        column = stub("column", key: :time, cells: [ 9000 ], precision: 3)
        assert_equal "0:00:12.000", TimeRenderer.render(column, row)

        row = stub("row", "[]" => 12)
        column = stub("column", key: :time, cells: [ 9000 ], precision: 4)
        assert_equal "0:00:12.000", TimeRenderer.render(column, row)
      end
    end
  end
end
