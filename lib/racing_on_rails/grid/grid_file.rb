module RacingOnRails
  module Grid
    # Read and write Grid to files. To be replaced by Tabular.
    class GridFile < RacingOnRails::Grid::Grid

      def GridFile.read_excel(file)
        Rails.logger.debug("GridFile (#{Time.zone.now}) read_excel #{file}")
        if File::Stat.new(file.path).size == 0
          Rails.logger.warn("#{file.path} is empty")
          return []
        end

        excel_rows = []
        ::Spreadsheet.open(file.path)
        ::Spreadsheet.open(file.path).worksheets.each do |worksheet|
          worksheet.each do |row|
            if Rails.logger.debug? && debug?
              Rails.logger.debug("---------------------------------") 
              Rails.logger.debug("GridFile #{Time.zone.now} row #{row.to_a.join(', ')}")
              row.each_with_index do |cell, index|
                Rails.logger.debug("number_format pattern to_s to_f #{row.format(index).number_format}  #{row.format(index).pattern} #{cell.to_s} #{cell.to_f if cell.respond_to?(:to_f)} #{cell.class}")
              end
              Rails.logger.debug("---------------------------------") 
            end
            line = []
            for cell in row
              case cell
              when NilClass
                line << ""
              when String
                line << cell.strip
              when Date, DateTime, Time
                line << cell.to_s(:db)
              when Float
                if cell.to_f == cell.to_i
                  line << cell.to_i.to_s
                else
                  line << cell.to_s
                end
              when Numeric
                line << cell.to_s
              else
                if cell.respond_to?(:to_s)
                  line << cell.to_s.strip
                else
                  line << ""
                end
              end
            end
            if !line.empty? && !line.all? { |c| c.nil? || (c.respond_to?(:blank?) && c.blank?) }
              excel_rows << line
            end
          end
        end
        Rails.logger.debug("GridFile (#{Time.zone.now}) read #{excel_rows.size} rows")
        excel_rows
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
          raise "#{source} does not exist" unless File.exists?(source.path)
          @file = source
          if excel?
            lines = GridFile.read_excel(@file)
          else
            lines = source.readlines
          end
          super(lines, options)

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
  end
end
