require_relative "../../../test_case"
require "active_support/core_ext/string/inflections"
require "tabular"
require_relative "../../../../../app/helpers/results/renderers/default_result_renderer"

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
    end
  end
end
