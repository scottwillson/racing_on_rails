require "helper"

module Tabular
  class RowTest < Test::Unit::TestCase
    def test_new
      row = Row.new([])
      assert_equal nil, row[:city], "[]"
      
      assert_equal "", row.join, "join"
      assert_equal({}, row.to_hash, "to_hash")
      assert_equal "{}", row.inspect, "inspect"
      assert_equal "", row.to_s, "to_s"
      
      # Test each
      row.each { |c| c.nil? }
    end
    
    def test_set
      columns = Columns.new([ "planet", "star" ])
      row = Row.new(columns, [ "Mars", "Sun" ])
      
      assert_equal "Sun", row[:star], "row[:star]"
      
      row[:star] = "Solaris"
      assert_equal "Solaris", row[:star], "row[:star]"
      
      row[:astronaut] = "Buzz"
      assert_equal "Buzz", row[:astronaut], "row[:astronaut]"
    end
    
    def test_join
      columns = Columns.new([ "planet", "star" ])
      row = Row.new(columns, [ "Mars", "Sun" ])
      assert_equal "MarsSun", row.join, "join"
      assert_equal "Mars-Sun", row.join("-"), "join '-'"
    end
    
    def test_to_hash
      columns = Columns.new([ "planet", "star" ])
      row = Row.new(columns, [ "Mars", "Sun" ])
      assert_equal({ :planet => "Mars", :star => "Sun"}, row.to_hash, "to_hash")
    end
    
    def test_inspect
      columns = Columns.new([ "planet", "star" ])
      row = Row.new(columns, [ "Mars", "Sun" ])
      assert_equal "{:planet=>\"Mars\", :star=>\"Sun\"}", row.inspect, "inspect"
    end
    
    def test_to_s
      columns = Columns.new([ "planet", "star" ])
      row = Row.new(columns, [ "Mars", "Sun" ])
      assert_equal "Mars, Sun", row.to_s, "to_s"
    end
  end
end

