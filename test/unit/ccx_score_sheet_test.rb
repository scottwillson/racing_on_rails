require File.dirname(__FILE__) + '/../test_helper'
require 'parseexcel/parseexcel'

class CcxScoreSheetTest < Test::Unit::TestCase
  
  def setup
    super
    @path = File.expand_path("#{RAILS_ROOT}/tmp/ccx_score_sheet.xls")
    if File.exists?(@path)
      FileUtils.rm(@path)
    end
    assert(!File.exists?(@path), "#{@path} should not exist")
  end
  
  def test_save
    score_sheet = CcxScoreSheet.new(@path)
    score_sheet.save!
    assert(File.exists?(@path), "#{@path} should exist")
    workbook = Spreadsheet::ParseExcel.parse(@path)
    assert_equal(3, workbook.sheet_count, 'workbook.sheet_count')
  end
end
