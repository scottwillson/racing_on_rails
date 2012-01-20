module Results
  # Used by ResultsFile. Intermediate Hash-like model between Excel row and Result.
  class Row
    attr_reader :column_indexes
    attr_accessor :next
    attr_accessor :previous
    attr_accessor :result
    attr_reader :spreadsheet_row
    attr_reader :usac_results_format

    def initialize(spreadsheet_row, column_indexes, usac_results_format)
      @spreadsheet_row = spreadsheet_row
      @column_indexes = column_indexes
      @usac_results_format = usac_results_format
    end

    def [](column_symbol)
      index = column_indexes[column_symbol]
      if index
        case spreadsheet_row[index]
        when ::Spreadsheet::Formula
          value = spreadsheet_row[index].value
        when ::Spreadsheet::Excel::Error
          value = nil
        else
          value = spreadsheet_row[index]
        end
        value.strip! if value.respond_to?(:strip!)
        value
      end
    end

    def to_hash
      hash = Hash.new
      column_indexes.keys.each { |key| hash[key] = self[key] }
      hash
    end

    def blank?
      spreadsheet_row.all? { |cell| cell.to_s.blank? }
    end

    def first
      spreadsheet_row[0]
    end

    def first?
      spreadsheet_row.idx == 0
    end

    def last?
      spreadsheet_row == spreadsheet_row.worksheet.last_row
    end

    def size
      spreadsheet_row.size
    end

    def place
      if column_indexes[:place]
        value = self[:place]
      else
        value = spreadsheet_row[0]
        value = spreadsheet_row[0].value if spreadsheet_row[0].is_a?(::Spreadsheet::Formula)
        value.strip! if value.respond_to?(:strip!)
      end

      # Mainly to handle Dates and DateTimes in the place column
      value = nil unless value.respond_to?(:to_i)
      value
    end

    def same_time?
      if previous && self[:time].present?
        row_time = self[:time].try(:to_s)
        row_time && (row_time[/st/i] || row_time[/s\.t\./i])
      end
    end

    def notes
      if usac_results_format
        # We want to pick up the info in the first 5 columns: org, year, event #, date, discipline
        return "" if blank? || size < 5
        spreadsheet_row[0, 5].select { |cell| cell.present? }.join(", ")
      else  
        return "" if blank? || size < 2
        spreadsheet_row[1, size - 1].select { |cell| cell.present? }.join(", ")
      end
    end

    def to_s
      "#<Results::ResultsFile::Row #{spreadsheet_row.to_a.join(', ')} >"
    end
  end
end
