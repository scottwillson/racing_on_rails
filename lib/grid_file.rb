require 'parseexcel/parseexcel'

# TODO Handle Excel with multiple sheet. Array of Grids?
# TODO Handle logging better

class GridFile < Grid
  
  TIME_FORMATS = [18, 19, 21, 22, 25, 27, 44] unless defined?(TIME_FORMATS)

  def GridFile.read_excel(file)
    RACING_ON_RAILS_DEFAULT_LOGGER.debug("GridFile (#{Time.now}) read_excel #{file}")
    if File::Stat.new(file.path).size == 0
      RACING_ON_RAILS_DEFAULT_LOGGER.warn("#{file.path} is empty")
      return []
    end

    excel_rows = []
    workbook = Spreadsheet::ParseExcel.parse(file.path)
    return [] if workbook.sheet_count == 0

    for workbook_index in 0..(workbook.sheet_count - 1)
      worksheet = workbook.worksheet(workbook_index)
      for row in worksheet
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("GridFile (#{Time.now}) #{row}")
        if row
          line = []
          is_not_blank = true
          for cell in row
            if cell
              # RACING_ON_RAILS_DEFAULT_LOGGER.debug("format: #{cell.format_no} to_s: #{cell.to_s} to_f: #{cell.to_f}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
              # RACING_ON_RAILS_DEFAULT_LOGGER.debug("date: #{cell.date}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
              is_time = TIME_FORMATS.include?(cell.format_no)
              cell_f = cell.to_f if is_time
              if is_time and cell_f < 2 and cell.to_s == cell_f.to_s
                is_not_blank = true
                line << (cell_f * 86400).to_s
              elsif cell.type == :date
                is_not_blank = true
                line << cell.date.to_s
              elsif cell.type == :numeric
                is_not_blank = true unless cell == 0
                line << cell.to_i.to_s
              else
                is_not_blank = true unless cell.to_s.strip.blank?
                line << cell.to_s
              end
            else
              line << ""
            end
          end
          if !line.empty? && is_not_blank
            excel_rows << line
          end
        end
      end
    end
    RACING_ON_RAILS_DEFAULT_LOGGER.debug("GridFile (#{Time.now}) read #{excel_rows.size} rows")
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
        raise "#{source} does not exist" unless File.exists?(source.path)
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
