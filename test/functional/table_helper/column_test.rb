require File.dirname(__FILE__) + '/../../test_helper'

module TableHelper
  class ColumnTest < ActiveSupport::TestCase
    def test_new
      table = Table.new(:racers)
      column = TableHelper::Column.new(table, :name)
      assert_equal("Name", column.title, "title")
      assert_equal(:name, column.attribute, "attribute")
      assert_equal("name", column.style_class, "style_class")
      assert_equal(false, column.link, "link")
      assert_equal(false, column.editable?, "editable")
      assert_equal(nil, column.format, "format")
      assert_equal(table, column.table, "table")
      assert_equal([:name], column.sort_by, "sort_by")
    end

    def test_options
      table = Table.new(:racers)
      column = TableHelper::Column.new(table, :team, :title => "Equipe", :style_class => "team_name", :format => "%a %m/%d", :link => true, 
                                       :editable => true, :sort_by => [:last_name, :first_name])
      assert_equal("Equipe", column.title, "title")
      assert_equal("team_name", column.style_class, "style_class")
      assert_equal(:team, column.attribute, "attribute")
      assert_equal(true, column.link?, "link")
      assert_equal(true, column.editable?, "editable")
      assert_equal("%a %m/%d", column.format, "format")
      assert_equal(table, column.table, "table")
      assert_equal([:last_name, :first_name], column.sort_by, "sort_by")
    end
    
    def test_table_sorted_by_different_attribute
      table = Table.new(:racers, nil, nil, "team_name", "desc")
      column = TableHelper::Column.new(table, :name)
      assert_equal([:name], column.sort_by, "sort_by")
      assert_equal("asc", column.sort_direction, "sort_direction")
    end
    
    def test_table_sorted_by_same_attribute_asc
      table = Table.new(:racers, nil, nil, "name", "asc")
      column = TableHelper::Column.new(table, :name)
      assert_equal([:name], column.sort_by, "sort_by")
      assert_equal("desc", column.sort_direction, "sort_direction")
    end
    
    def test_table_sorted_by_same_attribute_desc
      table = Table.new(:racers, nil, nil, "name", "desc")
      column = TableHelper::Column.new(table, :name)
      assert_equal([:name], column.sort_by, "sort_by")
      assert_equal("asc", column.sort_direction, "sort_direction")
    end
    
    def test_table_sorted_by_many_different_attribute
      table = Table.new(:racers, nil, nil, "first_name,last_name", "asc")
      column = TableHelper::Column.new(table, :name)
      assert_equal([:name], column.sort_by, "sort_by")
      assert_equal("asc", column.sort_direction, "sort_direction")
    end
    
    def test_table_sorted_by_many_same_attribute_asc
      table = Table.new(:racers, nil, nil, "first_name,last_name", "asc")
      column = TableHelper::Column.new(table, [:first_name, :last_name])
      assert_equal([:first_name, :last_name], column.sort_by, "sort_by")
      assert_equal("desc", column.sort_direction, "sort_direction")
    end
    
    def test_table_sorted_by_many_same_attribute_desc
      table = Table.new(:racers, nil, nil, "first_name,last_name", "desc")
      column = TableHelper::Column.new(table, [:first_name, :last_name])
      assert_equal([:first_name, :last_name], column.sort_by, "sort_by")
      assert_equal("asc", column.sort_direction, "sort_direction")
    end
    
    def test_table_sorted_by_many_many_same_attribute_desc
      table = Table.new(:racers, nil, nil, "first_name,last_name,team_name,age", "desc")
      column = TableHelper::Column.new(table, [:first_name, :last_name, :team_name, :age])
      assert_equal([:first_name, :last_name, :team_name, :age], column.sort_by, "sort_by")
      assert_equal("asc", column.sort_direction, "sort_direction")
    end
  end
end
