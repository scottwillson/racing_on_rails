require_relative "../test_case"
require_relative "../../../lib/renderers/default_result_renderer"
require "active_support/core_ext/string/inflections"

# :stopdoc:
module Renderers
  class DefaultColumnRendererTest < Ruby::TestCase
    class ColumnStub
      attr_reader :key
      def initialize(key)
        @key = key
      end
    end

    test "render_key" do
      assert_equal "Foo", DefaultResultRenderer.render_header(:foo)
    end

    test "render_column" do
      column = ColumnStub.new(:foo)
      assert_equal "Foo", DefaultResultRenderer.render_header(column)
    end

    test "render_mapped_column" do
      column = ColumnStub.new(:category_name)
      assert_equal "Category", DefaultResultRenderer.render_header(column)
    end
  end
end
