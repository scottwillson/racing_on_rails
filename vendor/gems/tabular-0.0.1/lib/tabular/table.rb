module Tabular
  class Table
    attr_reader :columns, :rows
    
    def self.read(file_path, *options)
      raise "Could not find '#{file_path}'" unless File.exists?(file_path)
      
      case File.extname(file_path)
      when ".xls", ".xlsx"
        require "spreadsheet"
        # Row#to_a coerces Excel data to Strings, but we want Dates and Numbers
        data = []
        Spreadsheet.open(file_path).worksheets.first.each do |excel_row|
          data << excel_row.inject([]) { |row, cell| row << cell; row }
        end
      when ".txt"
        require "csv"
        data = ::CSV.open(file_path, "r","\t").collect { |row| row }
      when ".csv"
        require "fastercsv"
        data = FasterCSV.read(file_path)
      end
      
      Table.new data, options
    end
    
    def initialize(rows = [], *options)
      if options
        options = options.flatten.first || {}
      else
        options = {}
      end
      
      rows.each do |row|
        if columns
          @rows << Tabular::Row.new(columns, row)
        else
          @columns = Tabular::Columns.new(row, options[:columns])
          @rows = []
        end
      end
    end
    
    def [](index)
      rows[index]
    end
    
    def inspect
      rows.map { |row| row.join(",") }.join("\n")
    end
    
    def to_s
      "#<#{self.class} #{rows.size}>"
    end
  end
end
