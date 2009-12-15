require "helper"

module Tabular
  class ColumnTest < Test::Unit::TestCase
    def test_new_nil
      column = Column.new
      assert_equal nil, column.to_s, "blank column to_s"
      assert_equal nil, column.key, "blank column key"
    end
    
    def test_new
      assert_equal :date, Column.new("date").key, "column key"
      assert_equal :date, Column.new(:date).key, "column key"
      assert_equal :date, Column.new("Date").key, "column key"
      assert_equal :date, Column.new(" Date  ").key, "column key"
      assert_equal :date, Column.new("DATE").key, "column key"
      assert_equal :start_date, Column.new("StartDate").key, "column key"
      assert_equal :start_date, Column.new("Start Date").key, "column key"
    end
    
    def test_mapping
      assert_equal :city, Column.new(:location, :location => :city).key, "column key"
    end
    
    def test_type
      column = Column.new("name")
      assert_equal :name, column.key, "key"
      assert_equal :string, column.column_type, "column_type"
      
      column = Column.new("date")
      assert_equal :date, column.key, "key"
      assert_equal :date, column.column_type, "column_type"

      column = Column.new("phone", :phone => { :column_type => :integer })
      assert_equal :phone, column.key, "key"
      assert_equal :integer, column.column_type, "column_type"
    end
  end
end
