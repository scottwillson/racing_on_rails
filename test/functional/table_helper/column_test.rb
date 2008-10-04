require File.dirname(__FILE__) + '/../../test_helper'

module Table
  class ColumnTest < ActiveSupport::TestCase
    def test_new
      column = TableHelper::Column.new(:name)
      assert_equal("Name", column.title, "title")
      assert_equal(:name, column.attribute, "attribute")
      assert_equal("name", column.style_class, "style_class")
      assert_equal(false, column.link, "link")
      assert_equal(false, column.editable?, "editable")
      assert_equal(nil, column.format, "format")
    end

    def test_options
      column = TableHelper::Column.new(:team, :title => "Equipe", :style_class => "team_name", :format => "%a %m/%d", :link => true, :editable => true)
      assert_equal("Equipe", column.title, "title")
      assert_equal("team_name", column.style_class, "style_class")
      assert_equal(:team, column.attribute, "attribute")
      assert_equal(true, column.link?, "link")
      assert_equal(true, column.editable?, "editable")
      assert_equal("%a %m/%d", column.format, "format")
    end
  end
end
