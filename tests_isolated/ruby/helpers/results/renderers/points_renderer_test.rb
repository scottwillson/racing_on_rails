require_relative "../../../test_case"
require "tabular"
require_relative "../../../../../app/helpers/results/renderers/points_renderer"

module Results
  module Renderers
    # :stopdoc:
    class PointsRendererTest < Ruby::TestCase
      def test_render_nil
        row = Tabular::Table.new << { points: nil }
        assert_equal "", PointsRenderer.render(row.columns[:points], row)
      end

      def test_render_zero
        row = Tabular::Table.new << { points: 0 }
        assert_equal "", PointsRenderer.render(row.columns[:points], row)
      end

      def test_render_integer
        row = Tabular::Table.new << { points: 12 }
        assert_equal "12", PointsRenderer.render(row.columns[:points], row)
      end

      def test_pad_decimals
        row = Tabular::Table.new << { points: 12 }
        column = row.columns[:points]
        column.stubs(precision: 3)
        assert_equal "12.000", PointsRenderer.render(column, row)
      end
    end
  end
end
