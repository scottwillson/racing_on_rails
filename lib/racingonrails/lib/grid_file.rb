require 'parseexcel/parseexcel'

# TODO Handle Excel with multiple sheet. Array of Grids?
# TODO Handle logging better

module RacingOnRails
  class GridFile < Grid

    def GridFile.read_excel(file)
      if File::Stat.new(file.path).size == 0
        RACING_ON_RAILS_DEFAULT_LOGGER.warn("#{file.path} is empty")
        return []
      end

      excel_rows = []
      workbook = Spreadsheet::ParseExcel.parse(file.path)
      return [] if workbook.sheet_count == 0
  
      for row in workbook.worksheet(0)
        if row
          line = []
          for cell in row
            if cell
               #RACING_ON_RAILS_DEFAULT_LOGGER.debug("format: #{cell.format_no} to_s: #{cell.to_s} to_f: #{cell.to_f}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
               if(cell.format_no == 25 or cell.format_no == 30) and (cell.to_i > 5000)             
                 line << cell.date.to_s
               elsif cell.to_f > 0.0 and (cell.format_no == 25 or cell.format_no == 30 or cell.format_no == 42 or cell.format_no == 27 or cell.format_no == 44)
                   line << cell.to_f.to_s
              else
                line << cell.to_s
              end
            else
              line << ""
            end
          end
          excel_rows << line
        end
      end
      excel_rows
    end

    # source can be String or File
    # accept Tempfile for testing
    # header_row: start_at_row is header
    # FIXME Only honors start_at_row, header_row for Excel
    # FIXME Assumes all non-.txt files are Excel
    def initialize(source = nil, columns = nil)
      raise(ArgumentError, "'source' cannot be nil") if source.nil?
    
      case source
      when File, Tempfile
        begin
          @file = source
          if excel?
            lines = GridFile.read_excel(@file)
           else
             lines = source.readlines
           end
          if columns.nil?
            columns = lines.delete_at(0)
          end
          super(lines, columns)
        ensure
          source.close unless source == nil || source.closed?
        end

      when String
        super(source, columns)

      when Array
        if columns.nil?
          columns = source.delete_at(0)
        end
        super(source, columns)

      else
        raise(ArgumentError, "Expected String or File, but was #{source.class}")
      end
    end
  
    def save
      begin
        out = File.open(@file.path, File::WRONLY)
        for row in @rows
          for index in 0..(column_count - 1)
            out.write(row[index])
            out.write("\t") unless index == column_count - 1
          end
          out.write("\n")
        end
        out.flush
      ensure
        out.close unless out == nil || out.closed?
      end
    end
  
    def excel?
      return false if @file.nil?
      @file.path.include?('.xls')
    end
  end
end