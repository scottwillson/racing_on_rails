require_relative "../test_case"
require_relative "../../../lib/renderers/points_renderer"

# :stopdoc:
module Renderers
  class PointsRendererTest < Ruby::TestCase
    test "render_nil" do
      row = Tabular::Table.new << { points: nil }
      assert_equal "", PointsRenderer.render(row.columns[:points], row)
    end

    test "render_zero" do
      row = Tabular::Table.new << { points: 0 }
      assert_equal "", PointsRenderer.render(row.columns[:points], row)
    end

    test "render_integer" do
      row = Tabular::Table.new << { points: 12 }
      assert_equal "12", PointsRenderer.render(row.columns[:points], row)
    end

    test "pad_decimals" do
      row = Tabular::Table.new << { points: 12 }
      column = row.columns[:points]
      column.stubs(precision: 3)
      assert_equal "12.000", PointsRenderer.render(column, row)
    end
  end
end
