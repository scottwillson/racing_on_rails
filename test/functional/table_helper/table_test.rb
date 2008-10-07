require File.dirname(__FILE__) + '/../../test_helper'

module TableHelper
  class TableTest < ActiveSupport::TestCase
    def test_new
      table = Table.new(:events, [])
      assert_not_nil(table.columns, "columns")
      assert_not_nil(table.collection, "collection")
    end
      
    def test_new_with_args
      table = Table.new(:racers, "Members")
      assert_not_nil(table.columns, "columns")
      assert_equal(:racers, table.collection_symbol, "collection_symbol")
      assert_equal(:racer, table.record_symbol, "record_symbol")
      assert_not_nil(table.collection, "collection")
    end
      
    def test_column
      table = Table.new(:events, [])
      table.column(:name)
      table.column(:member)
      assert_equal(2, table.columns.size, "columns")
    end
  end
end