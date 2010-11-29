require "helper"

module Tabular
  class RowTest < Test::Unit::TestCase
    def test_new
      row = Row.new(Table.new)
      assert_equal nil, row[:city], "[]"
      
      assert_equal "", row.join, "join"
      assert_equal({}, row.to_hash, "to_hash")
      assert_equal "{}", row.inspect, "inspect"
      assert_equal "", row.to_s, "to_s"
      
      # Test each
      row.each { |c| c.nil? }
    end
    
    def test_set
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [ "Mars", "Sun" ])
      
      assert_equal "Sun", row[:star], "row[:star]"
      
      row[:star] = "Solaris"
      assert_equal "Solaris", row[:star], "row[:star]"
      
      row[:astronaut] = "Buzz"
      assert_equal "Buzz", row[:astronaut], "row[:astronaut]"
    end
    
    def test_join
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [ "Mars", "Sun" ])
      assert_equal "MarsSun", row.join, "join"
      assert_equal "Mars-Sun", row.join("-"), "join '-'"
    end
    
    def test_to_hash
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [ "Mars", "Sun" ])
      assert_equal({ :planet => "Mars", :star => "Sun"}, row.to_hash, "to_hash")
    end
    
    def test_inspect
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [ "Mars", "Sun" ])
      assert_match %r{:planet=>"Mars"}, row.inspect, "inspect"
      assert_match %r{:star=>"Sun"}, row.inspect, "inspect"
    end
    
    def test_to_s
      table = Table.new([[ "planet", "star" ]])
      row = Row.new(table, [ "Mars", "Sun" ])
      assert_equal "Mars, Sun", row.to_s, "to_s"
    end
    
    def test_previous
      table = Table.new([[ "planet", "star" ]])
      table << [ "Mars", "Sun" ]
      table << [ "Jupiter", "Sun" ]
      assert_equal nil, table.rows.first.previous, "previous of first Row"
      assert_equal "Mars", table.rows.last.previous[:planet], "previous"
    end
    
    def test_invalid_date_raises_exception
      table = Table.new([[ "launched" ]], :columns => { :launched => { :column_type => :date } })
      row = Row.new(table, [ "99/z/99" ])
      assert_raise ArgumentError do
        row[:launched]
      end
    end
    
    def test_parse_compact_american_dates
      table = Table.new([[ "launched" ]], :columns => { :launched => { :column_type => :date } })
      assert_equal Date.new(1999, 1, 1), Row.new(table, [ "1/1/99" ])[:launched], "1/1/99"
      assert_equal Date.new(2000, 8, 28), Row.new(table, [ "8/28/00" ])[:launched], "8/28/00"
      assert_equal Date.new(2008, 12, 31), Row.new(table, [ "12/31/08" ])[:launched], "12/31/08"
    end
  end
end

