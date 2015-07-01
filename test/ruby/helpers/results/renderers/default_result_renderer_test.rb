require_relative "../../../test_case"
require "active_support/core_ext/string/inflections"
require "tabular"
require_relative "../../../../../app/helpers/results/renderers/default_result_renderer"
require_relative "../../../../../app/helpers/results/renderers/time_renderer"

module Results
  module Renderers
    # :stopdoc:
    class DefaultResultRendererTest < Ruby::TestCase
      class ColumnStub
        attr_reader :key
        def initialize(key)
          @key = key
        end
      end

      def test_render_key
        assert_equal "Foo", DefaultResultRenderer.render_header(:foo)
      end

      def test_render_column
        column = ColumnStub.new(:foo)
        assert_equal "Foo", DefaultResultRenderer.render_header(column)
      end

      def test_render_mapped_column
        column = ColumnStub.new(:category_name)
        assert_equal "Category", DefaultResultRenderer.render_header(column)
      end

      def test_render
        column = stub("column", key: :city)
        row = stub("row", :[] => "Portland")
        assert_equal "Portland", DefaultResultRenderer.render(column, row), "City columns should render exact text"
      end

      def test_render_arbritrary_time
        column = stub("column", key: :best_time, precision: 0, max: 334)
        row = stub("row", :[] => 334)
        assert_equal "05:34", DefaultResultRenderer.render(column, row), "Columns with 'time' should render as times"

        column = stub("column", key: :time_down, precision: 0, max: 12)
        row = stub("row", :[] => 12)
        assert_equal "12", DefaultResultRenderer.render(column, row), "Columns with 'time' should render as times"
      end
    end
  end
end
