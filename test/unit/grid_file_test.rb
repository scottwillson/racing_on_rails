require File.dirname(__FILE__) + '/../test_helper'

require 'tempfile'
require 'parseexcel/format'
require 'parseexcel/workbook'
require 'parseexcel/worksheet'

class GridFileTest < ActiveSupport::TestCase

  def test_new
    assert_raise(ArgumentError) {GridFile.new(nil)}
  end

  def test_new_file
    file = File.new("#{File.dirname(__FILE__)}/../../test/fixtures/results/tabor.txt")
    grid_file = GridFile.new(file)
    assert_equal(35, grid_file.rows.size, "grid_file.rows.size")
    assert_equal("Dills", grid_file[20][3], "grid_file[20][3]")
  end
  
  def test_save
    file = Tempfile.new("test_results.txt")

    begin
      grid_file = GridFile.new(file)
      grid_file.rows = [
        ["Mary had a", "little"],
        ["", "lamb"]
      ]
      expected = [
        ["Mary had a", "little"],
        ["", "lamb"]
      ]
      assert_equal(expected, grid_file.rows, "unsaved file contents")
      grid_file.save
    ensure
      file.close if file && !file.closed?
    end
    expected = ["Mary had a\tlittle\n", "\tlamb\n"]
    begin
      file_to_read = File.new(file.path)
      lines = file_to_read.readlines
    ensure
      file_to_read.close if file_to_read && !file_to_read.closed?
    end
    
    assert_equal(expected, lines, "Saved file contents")
  end
  
  def test_read_cell_user_defined_time
    cell = Spreadsheet::ParseExcel::Worksheet::Cell.new
    cell.book = Spreadsheet::ParseExcel::Workbook.new
    format = Spreadsheet::ParseExcel::Format.new(:fmt_idx => 166)
    cell.format = format
    cell.format_no = 32
    cell.value = '3:45'
    cell.kind = :packed_idx
    cell.numeric = false
    
    result = GridFile.read_cell(cell)
    assert_equal('225.0', result, 'Expected cell value')
  end
  
  def test_read_cell_time_from_datetime
    cell = Spreadsheet::ParseExcel::Worksheet::Cell.new
    cell.book = Spreadsheet::ParseExcel::Workbook.new
    format = Spreadsheet::ParseExcel::Format.new(:fmt_idx => 165)
    format.add_text_format(165, "H:MM:SS")
    cell.format = format
    cell.format_no = 22
    cell.value = 0.0260648148148148
    cell.kind = :number
    cell.numeric = true
    
    result = GridFile.read_cell(cell)
    assert_equal('2252.0', result, 'Expected cell value')
  end
  
  def test_read_cell_m_ss
    cell = Spreadsheet::ParseExcel::Worksheet::Cell.new
    cell.book = Spreadsheet::ParseExcel::Workbook.new
    format = Spreadsheet::ParseExcel::Format.new(:fmt_idx => 164)
    format.add_text_format(164, 'm:ss.00')
    cell.format = format
    cell.format_no = 29
    cell.value = '2:52.28'
    cell.kind = :packed_idx
    cell.numeric = false
    
    result = GridFile.read_cell(cell)
    assert_equal('172.28', result, 'Expected cell value')
  end
  
  def test_read_cell_h_mm
    cell = Spreadsheet::ParseExcel::Worksheet::Cell.new
    cell.book = Spreadsheet::ParseExcel::Workbook.new
    format = Spreadsheet::ParseExcel::Format.new(:fmt_idx => 166)
    format.add_text_format(166, "H:MM")
    cell.format = format
    cell.format_no = 39
    cell.value = '3:52'
    cell.kind = :packed_idx
    cell.numeric = false
    
    result = GridFile.read_cell(cell)
    assert_equal('232.0', result, 'Expected cell value')
  end
  
  def test_read_cell_ampersand
    cell = Spreadsheet::ParseExcel::Worksheet::Cell.new
    cell.book = Spreadsheet::ParseExcel::Workbook.new
    format = Spreadsheet::ParseExcel::Format.new(:fmt_idx => 165)
    format.add_text_format(165, "@")
    cell.format = format
    cell.format_no = 40
    cell.value = '3:52'
    cell.kind = :packed_idx
    cell.numeric = false
    
    result = GridFile.read_cell(cell)
    assert_equal('232.0', result, 'Expected cell value')
  end
end