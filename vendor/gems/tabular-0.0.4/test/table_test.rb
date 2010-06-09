require "helper"

module Tabular
  class TableTest < Test::Unit::TestCase
    def test_read_from_blank_txt_file
      table = Table.read(File.expand_path(File.dirname(__FILE__) + "/fixtures/blank.txt"))
    end
    
    # "Place ","Number","Last Name","First Name","Team","Category Raced"
    # "1","189","Willson","Scott","Gentle Lover","Senior Men 1/2/3","11",,"11"
    # "2","190","Phinney","Harry","CCCP","Senior Men 1/2/3","9",,
    # "3","10a","Holland","Steve","Huntair","Senior Men 1/2/3",,"3",
    # "dnf","100","Bourcier","Paul","Hutch's","Senior Men 1/2/3",,,"1"
    def test_read_from_csv
      table = Table.read(File.expand_path(File.dirname(__FILE__) + "/fixtures/sample.csv"))
      assert_equal 4, table.rows.size, "rows"

      assert_equal "1", table[0][:place], "0.0"
      assert_equal "189", table[0][:number], "0.1"
      assert_equal "Willson", table[0][:last_name], "0.2"
      assert_equal "Scott", table[0][:first_name], "0.3"
      assert_equal "Gentle Lover", table[0][:team], "0.4"

      assert_equal "dnf", table[3][:place], "3.0"
      assert_equal "100", table[3][:number], "3.1"
      assert_equal "Bourcier", table[3][:last_name], "3.2"
      assert_equal "Paul", table[3][:first_name], "3.3"
      assert_equal "Hutch's", table[3][:team], "3.4"
    end
    
    def test_read_from_excel
      table = Table.read(File.expand_path(File.dirname(__FILE__) + "/fixtures/excel.xls"))
      assert_equal Date.new(2006, 1, 20), table[0][:date], "0.0"
    end
    
    def test_read_from_excel_file
      table = Table.read(File.new(File.expand_path(File.dirname(__FILE__) + "/fixtures/excel.xls")))
      assert_equal Date.new(2006, 1, 20), table[0][:date], "0.0"
    end
    
    def test_read_as
      table = Table.read(File.expand_path(File.dirname(__FILE__) + "/fixtures/sample.lif"), :as => :csv)
      assert_equal 4, table.rows.size, "rows"
    end
    
    def test_column_map
      data = [
        [ "nom", "equipe", "homme" ],
        [ "Hinault", "Team Z", "true" ]
      ]
      table = Table.new(data, :columns => { :nom => :name, :equipe => :team, :homme => { :column_type => :boolean } })
      assert_equal "Hinault", table.rows.first[:name], ":name"
      assert_equal "Team Z", table.rows.first[:team], ":team"
      assert_equal true, table.rows.first[:homme], "boolean"
    end
  end
end
