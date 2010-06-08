require "helper"

module Tabular
  class ColumnsTest < Test::Unit::TestCase
    def test_new_blank
      columns = Columns.new([])
      assert_equal false, columns.has_key?(:name), "has_key? :name"
      assert_equal nil, columns[:name], "[:name]"
      assert_equal nil, columns.index(nil), "index"
      assert_equal nil, columns.index(""), "index"
      assert_equal nil, columns.index(:name), "index"
      columns.each { |c| c.nil? }
    end
    
    def test_new
      columns = Columns.new(["date", "first name", "LastName"])
      assert_equal false, columns.has_key?(:location), "has_key? :location"
      assert_equal true, columns.has_key?(:date), "has_key? :date"
      assert_equal true, columns.has_key?(:first_name), "has_key? :first_name"
      assert_equal true, columns.has_key?(:last_name), "has_key? :last_name"
      assert_equal false, columns.has_key?("first name"), "has_key? 'first name'"
      
      column = columns[:first_name]
      assert_equal :first_name, column.key, "column[:first_name] Column key"

      assert_equal 1, columns.index(:first_name), "index of :first_name"
    end
    
    def test_columns_map
      columns = Columns.new(["date"], :start_date => :date)
      assert_equal true, columns.has_key?(:date), "has_key? :date"
      assert_equal false, columns.has_key?(:start_date), "has_key? :start_date"
    end
    
    def test_each
      columns = Columns.new(["date", "first name", "LastName"])
      columns_from_each = []
      columns.each { |c| columns_from_each << c.key }
      assert_equal [ :date, :first_name, :last_name ], columns_from_each, "column keys from #each"
    end
    
    def test_push_onto_blank
      columns = Columns.new([])
      columns << "city state"
      assert_equal true, columns.has_key?(:city_state), "has_key? :city_state"
      assert_equal 0, columns.index(:city_state), "index of new column"

      column = columns[:city_state]
      assert_equal :city_state, column.key, "column[:city_state] Column key"
    end
    
    def test_push
      columns = Columns.new(["first", "second"])
      columns << "third"
      assert_equal true, columns.has_key?(:third), "has_key? :third"
      assert_equal 0, columns.index(:first), "index of existing column"
      assert_equal 1, columns.index(:second), "index of existing column"
      assert_equal 2, columns.index(:third), "index of new column"

      column = columns[:third]
      assert_equal :third, column.key, "column[:third] Column key"
    end
  end
end
