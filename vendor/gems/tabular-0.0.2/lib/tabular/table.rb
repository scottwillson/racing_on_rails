module Tabular
  # Simple Enumerable list of Hashes. Use Table.read(file_path) to read file.
  class Table
    attr_reader :rows
    
    # Assumes .txt = tab-delimited, .csv = CSV, .xls = Excel. Assumes first row is the header.
    # Normalizes column names to lower-case with underscores.
    def self.read(file_path, *options)
      raise "Could not find '#{file_path}'" unless File.exists?(file_path)
      options = extract_options(options)
      as = options.delete(:as)
      
      if as.present?
        format = as
      else
        format = case File.extname(file_path)
        when ".xls", ".xlsx"
          :xls
        when ".txt"
          :txt
        when ".csv"
          :csv
        end
      end
      
      case format
      when :xls
        require "spreadsheet"
        # Row#to_a coerces Excel data to Strings, but we want Dates and Numbers
        data = []
        Spreadsheet.open(file_path).worksheets.first.each do |excel_row|
          data << excel_row.inject([]) { |row, cell| row << cell; row }
        end
      when :txt
        require "csv"
        data = ::CSV.open(file_path, "r","\t").collect { |row| row }
      when :csv
        require "fastercsv"
        data = FasterCSV.read(file_path)
      else
        raise "Cannot read '#{format}' format. Expected :xls, :xlsx, :txt, or :csv"
      end
      
      Table.new data, options
    end
    
    # Pass data in as +rows+. Expects rows to be an Enumerable of Enumerables. 
    # Maps rows to Hash-like Tabular::Rows.
    #
    # Options:
    # :columns => { :original_name => :preferred_name, :column_name => { :column_type => :boolean } }
    def initialize(rows = [], *options)
      options = Table.extract_options(options)
      @rows = []
      
      rows.each do |row|
        if @columns
          self << row
        else
          @columns = Tabular::Columns.new(row, options[:columns])
        end
      end
    end
    
    # Return Row at zero-based index, or nil if Row is out of bounds
    def [](index)
      rows[index]
    end
    
    def <<(row)
      @rows << Tabular::Row.new(self, row)
    end
    
    def inspect
      rows.map { |row| row.join(",") }.join("\n")
    end
    
    def columns
      @columns || Tabular::Columns.new([])
    end
    
    def to_s
      "#<#{self.class} #{rows.size}>"
    end


    private
    
    def self.extract_options(options)
      if options
        options.flatten.first || {}
      else
        {}
      end
    end
  end
end
