require 'parseexcel/parseexcel'

# TODO Handle Excel with multiple sheet. Array of Grids?
# TODO Handle logging better

class GridFile < Grid
  
  DATE_FORMATS = [24, 25, 27, 28, 30, 42, 45]

  def GridFile.read_excel(file)
    if File::Stat.new(file.path).size == 0
      RACING_ON_RAILS_DEFAULT_LOGGER.warn("#{file.path} is empty")
      return []
    end

    excel_rows = []
    workbook = Spreadsheet::ParseExcel.parse(file.path)
    return [] if workbook.sheet_count == 0

    for workbook_index in 0..(workbook.sheet_count - 1)
      for row in workbook.worksheet(workbook_index)
        if row
          line = []
          for cell in row
            if cell
               RACING_ON_RAILS_DEFAULT_LOGGER.debug("format: #{cell.format_no} to_s: #{cell.to_s} to_f: #{cell.to_f}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
               if DATE_FORMATS.include?(cell.format_no) and cell.to_i > 5000
                 line << cell.date.to_s
               elsif cell.to_f > 0.0 and DATE_FORMATS.include?(cell.format_no) and cell.to_f.to_s == cell.to_s
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
    end
    excel_rows
  end

  # source can be String or File
  # accept Tempfile for testing
  # header_row: start_at_row is header
  # FIXME Only honors start_at_row, header_row for Excel
  # FIXME Assumes all non-.txt files are Excel
  def initialize(source, *options)  
    case source
    when File, Tempfile
      begin
        @file = source
        if excel?
          lines = GridFile.read_excel(@file)
        else
          lines = source.readlines
        end
        super(lines, options)
      ensure
        source.close unless source == nil || source.closed?
      end

    when String
      super(source, options)

    when Array
      super(source, options)

    else
      raise(ArgumentError, "Expected String or File, but was #{source.class}")
    end
  end

  def save
    begin
      out = File.open(@file.path, File::WRONLY)
      for row in rows
        for index in 0..(column_count - 1)
          out.write(row[index])
          out.write("\t") unless index == (column_count - 1)
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
