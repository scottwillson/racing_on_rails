require 'parseexcel/parseexcel'

# TODO Handle Excel with multiple sheet. Array of Grids?
# TODO Handle logging better

class GridFile < Grid
  
  TIME_FORMATS = [0, 18, 19, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 39, 40, 43, 44, 49, 50, 76] unless defined?(TIME_FORMATS)

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
        if RACING_ON_RAILS_DEFAULT_LOGGER.debug? && debug?
          RACING_ON_RAILS_DEFAULT_LOGGER.debug("---------------------------------") 
          RACING_ON_RAILS_DEFAULT_LOGGER.debug("GridFile (#{Time.now}) #{row}")
          RACING_ON_RAILS_DEFAULT_LOGGER.debug("---------------------------------") 
        end
        if row
          line = []
          is_blank = true
          for cell in row
            is_blank = false if !cell.to_s.strip.blank? || cell != 0
            _cell = read_cell(cell)
            line << _cell
          end
          if !line.empty? && !is_blank
            excel_rows << line
          end
        end
      end
    end
    RACING_ON_RAILS_DEFAULT_LOGGER.debug("GridFile (#{Time.now}) read #{excel_rows.size} rows")
    excel_rows
  end
  
  def GridFile.read_cell(cell)
    if cell
      if RACING_ON_RAILS_DEFAULT_LOGGER.debug? && debug?
        RACING_ON_RAILS_DEFAULT_LOGGER.debug('') 
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("format_no: #{cell.format_no}") 
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("fmt_idx:   #{cell.format.fmt_idx}") 
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("type:      #{cell.type}") 
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("value:     #{cell.value}") 
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("kind:      #{cell.kind}") 
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("numeric:   #{cell.numeric}")
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("code:      #{cell.code}")
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("to_s:      #{cell.to_s}") 
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("to_f:      #{cell.to_f}") 
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("date:      #{cell.date}")
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("datetime:  #{cell.datetime.year}-#{cell.datetime.month}-#{cell.datetime.day} #{cell.datetime.hour}:#{cell.datetime.min}.#{cell.datetime.sec} #{cell.datetime.msec}")
      end
      
      cell_f = cell.to_f
      cell_i = cell.to_i
      cell_type = cell.type
      if cell_type == :numeric and cell.format_no != 0
        if cell_f == cell_i
          return cell_i.to_s
        else
          return cell.to_f.to_s
        end
      end
      
      is_time = TIME_FORMATS.include?(cell.format_no) && (cell.to_s[/^\d*:\d+\.?\d?$/] || cell.to_s[/^\d*:?\d+\.\d+$/])
      if is_time and cell_f < 2 and cell.to_s == cell_f.to_s
        if cell_f == cell_i
          return (cell_i * 86400).to_s
        else
          return (cell_f * 86400).to_s
        end
      elsif cell_type == :text && is_time
        return s_to_time(cell.value).to_s
      elsif cell_type == :date
        date = cell.date.to_s
        if date.blank?
          if cell_f == cell_i
            return (cell_i * 86400).to_s
          else
            return  (cell_f * 86400).to_s
          end
        else
          return date
        end
      else
        return cell.to_s
      end
    end
    ''
  end
  
  def GridFile.debug?
    false
  end

  
  # TODO Dupe method
  # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
  # This method doesn't handle some typical edge cases very well
  def GridFile.s_to_time(string)
    if string.to_s.blank?
      0.0
    else
      string.gsub!(',', '.')
      parts = string.to_s.split(':')
      parts.reverse!
      t = 0.0
      parts.each_with_index do |part, index|
        t = t + (part.to_f) * (60.0 ** index)
      end
      t
    end    
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
