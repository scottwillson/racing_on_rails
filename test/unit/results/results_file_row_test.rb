require File.expand_path("../../../test_helper", __FILE__)
require "tempfile"
require "spreadsheet"

# :stopdoc:
module Results
  class ResultsFileRowTest < ActiveSupport::TestCase
    def test_create_row
      book = Spreadsheet.open(File.expand_path("../../../files/results/pir_2006_format.xls", __FILE__))
      spreadsheet_row = book.worksheet(0).row(0)
      Results::Row.new(spreadsheet_row, {}, false)
    end
  
    def test_row_last?
      book = Spreadsheet.open(File.expand_path("../../../files/results/pir_2006_format.xls", __FILE__))
      spreadsheet_row = book.worksheet(0).row(0)

      row = Results::Row.new(spreadsheet_row, {}, false)
      assert !row.last?, "Last row?"

      spreadsheet_row = book.worksheet(0).last_row
      row = Results::Row.new(spreadsheet_row, {}, false)
      assert row.last?, "Last row?"
    end
  
    def test_hash_access
      book = Spreadsheet.open(File.expand_path("../../../files/results/pir_2006_format.xls", __FILE__))
      spreadsheet_row = book.worksheet(0).row(2)

      row = Results::Row.new(spreadsheet_row, { :place => 0, :last_name => 3 }, false)
      assert_nil row[:city], "Non existent column"
      assert_equal 1, row[:place], "place"
      assert_equal "Elken", row[:last_name], "last_name"
    end
  end
end
