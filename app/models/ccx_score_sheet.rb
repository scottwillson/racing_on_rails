require 'spreadsheet/excel'

class CcxScoreSheet

  include Spreadsheet
  
  def initialize(path)
    @path = path
  end
  
  def save!
    workbook = Excel.new(@path)
    workbook.add_worksheet
    workbook.add_worksheet
    workbook.add_worksheet
    workbook.close
  end
end