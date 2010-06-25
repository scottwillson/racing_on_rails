require "spreadsheet"

module Results
  # Result time limited to hundredths of seconds
  #
  # TODO improve naming. Attribute keys? Hash keys?
  # TODO Ensure blank rows aren't processed
  #
  # Notes example:
  # Senior Men Pro 1/2 | Field size: 79 riders | Laps: 2
  #
  # Set DEBUG_RESULTS to Toggle expensive debug logging. E.g., DEBUG_RESULTS=yes ./script/server
  class ResultsFile
    attr_accessor :columns
    attr_accessor :column_indexes
    attr_accessor :event
    attr_accessor :rows
    attr_accessor :source

    # All custom columns in file
    attr_accessor :custom_columns
    
    # Custom columns just for Race
    attr_accessor :race_custom_columns

    COLUMN_MAP = {
      "placing"           => "place",
      ";place"            => "place",
      "#"                 => "number",
      "wsba#"             => "number",
      "rider_#"           => "number",
      'racing_age'        => 'age',
      'age'               => 'age',
      "gender"            => "gender",
      "barcategory"       => "parent",
      "bar_category"      => "parent",
      "category.name"     => "category_name",
      "categories"        => "category_name",
      "category"          => "category_name",
      "cat."              => "category_name",
      "class"             => "category_class",  # Example: A for Masters A
      "first"             => "first_name",
      "firstname"         => "first_name",
      "person.first_name" => "first_name",
      "person"            => "name",
      "lane"              => "category_name",
      "last"              => "last_name",
      "lastname"          => "last_name",
      "person.last_name"  => "last_name",
      "team"              => "team_name",
      "team.name"         => "team_name",
      "bib_#"             => "number",
      "obra_number"       => "number",
      "oregoncup"         => "oregon_cup",
      "membership_#"      => "license",
      "membership"        => "license",
      "license_#"         => "license",
      "club/team"         => "team_name",
      "hometown"          => 'city',
      "stage_time"        => "time",
      "st"                => "time",
      "stop_time"         => "time",
      "bonus"             => "time_bonus_penalty",
      "penalty"           => "time_bonus_penalty",
      "stage_+_penalty"   => "time_total",
      "time"              => "time",
      "time_total"        => "time_total",
      "total_time"        => "time_total",
      "down"              => "time_gap_to_leader",
      "gap"               => "time_gap_to_leader",
      "delta_time"        => "time_gap_to_leader",
      "pts"               => "points",
      "sex"               => "gender"
    }

    def initialize(source, event)
      self.column_indexes = nil
      self.event = event
      self.custom_columns = Set.new
      self.race_custom_columns = Set.new
      self.source = source
    end

    def import
      Rails.logger.info("Results::ResultsFile #{Time.zone.now} import")

      Event.transaction do
        event.disable_notification!
        book = Spreadsheet.open(source.path)
        book.worksheets.each do |worksheet|
          race = nil
          create_rows(worksheet)

          rows.each do |row|
            Rails.logger.debug("Results::ResultsFile #{Time.zone.now} row #{row.spreadsheet_row.to_a.join(', ')}") if debug?
            if race?(row)
              race = find_or_create_race(row)
              # This row is also a result. I.e., no separate race header row.
              if usac_results_format?
                create_result(row, race)
              end
            elsif result?(row)
              create_result(row, race)
            end
          end
        end
        event.enable_notification!
        CombinedTimeTrialResults.create_or_destroy_for!(event)
      end
      Rails.logger.info("Results::ResultsFile #{Time.zone.now} import done")
    end

    def create_rows(worksheet)
      # Need all rows. Decorate them before inspecting them.
      # Drop empty ones
      self.rows = []
      previous_row = nil
      worksheet.each do |spreadsheet_row|
        if debug?
          Rails.logger.debug("Results::ResultsFile #{Time.zone.now} row #{spreadsheet_row.to_a.join(', ')}")
          spreadsheet_row.each_with_index do |cell, index|
            Rails.logger.debug("number_format pattern to_s to_f #{spreadsheet_row.format(index).number_format}  #{spreadsheet_row.format(index).pattern} #{cell.to_s} #{cell.to_f if cell.respond_to?(:to_f)} #{cell.class}")
          end
        end
        row = Results::ResultsFile::Row.new(spreadsheet_row, column_indexes, usac_results_format?)
        unless row.blank?
          if column_indexes.nil?
            create_columns(spreadsheet_row)
          else
            row.previous = previous_row
            previous_row.next = row if previous_row
            rows << row
            previous_row = row
          end
        end
      end
    end

    # Create Hash of normalized column name indexes
    # Convert column names to lowercase and underscore. Use COLUMN_MAP to normalize.
    #
    # Example:
    # Place, Num, First Name
    # { :place => 0, :number => 1, :first_name => 2 }
    def create_columns(spreadsheet_row)
      self.column_indexes = Hash.new
      self.columns = []
      spreadsheet_row.each_with_index do |cell, index|
        cell_string = cell.to_s
        if index == 0 && cell_string.blank?
          column_indexes[:place] = 0
        elsif cell_string.present?
          cell_string.strip!
          cell_string.gsub!(/^"/, '')
          cell_string.gsub!(/"$/, '')
          cell_string = cell_string.downcase.underscore
          cell_string.gsub!(" ", "_")
          cell_string = COLUMN_MAP[cell_string] if COLUMN_MAP[cell_string]
          if cell_string.present?
            if usac_results_format?
              if Race::RESULT.respond_to?(cell_string.to_sym)
                column_indexes[cell_string.to_sym] = index
                self.columns << cell_string 
              end
            else
              column_indexes[cell_string.to_sym] = index
              self.columns << cell_string 
              if !Race::RESULT.respond_to?(cell_string.to_sym)
                self.custom_columns << cell_string
                self.race_custom_columns << cell_string
              end
            end
          end
        end
      end

      Rails.logger.debug("Results::ResultsFile #{Time.zone.now} Create column indexes #{self.column_indexes.inspect}") if debug?
      self.column_indexes
    end

    def race?(row)
      if usac_results_format?
        #new race when one of the key fields changes: category, gender, class or age if age is a range
        #i was looking for place = 1 but it is possible that all in race were dq or dnf or dns
        return false if column_indexes.nil? || row.blank?
        return true if row.previous.blank?
        #break if age is a range and it has changed
        if row[:age].present? && /\d+-\d+/ =~ row[:age].to_s
          return true unless row[:age] == row.previous[:age]
        end
        return false if row[:category_name] == row.previous[:category_name] && row[:gender] == row.previous[:gender] && row[:category_class] == row.previous[:category_class]
        return true
      else  
        return false if column_indexes.nil? || row.last? || row.blank? || (row.next && row.next.blank?)
        return false if row.place && row.place.to_i != 0
        row.next && row.next.place && row.next.place.to_i == 1
      end
    end

    def find_or_create_race(row)
      if usac_results_format?
        category = Category.find_or_create_by_name(construct_usac_category(row))
      else
        category = Category.find_or_create_by_name(row.first)
      end
      race = event.races.detect { |race| race.category == category }
      if race
        race.results.clear
      else
        race = event.races.build(:category => category, :notes => row.notes)
      end
      race.result_columns = columns
      race.custom_columns = race_custom_columns.to_a
      race_custom_columns = Set.new
      race.save!
      Rails.logger.info("Results::ResultsFile #{Time.zone.now} create race #{category}")
      race
    end

    def construct_usac_category(row)
      #category_name and gender should always be populated.
      #juniors, and conceivably masters, may be split by age group in which case the age column should
      #contain the age range. otherwise it may be empty or contain an individual racer's age.
      #The end result should look like "Junior Women 13-14" or "Junior Men"
      #category_class may or may not be populated
      #e.g. "Master B Men" or "Cat4 Female"
      if row[:age].present? && /\d+-\d+/ =~ row[:age].to_s
        return ((row[:category_name].to_s + " " + row[:category_class].to_s + " " + row[:gender].to_s + " " + row[:age].to_s)).squeeze(" ").strip
      else
        return ((row[:category_name].to_s + " " + row[:category_class].to_s + " " + row[:gender].to_s)).squeeze(" ").strip
      end
    end

    def result?(row)
      return false unless column_indexes
      return false if row.blank?
      return true if row.place.present? || row[:number].present? || row[:license].present? || row[:team_name].present?
      if !(row[:first_name].blank? && row[:last_name].blank? && row[:name].blank?)
        return true
      end
      false
    end

    def create_result(row, race)
      if race
        result = race.results.build(result_attributes(row, race))
        result.updated_by = @event.name

        if row.same_time?
          result.time = row.previous.result.time
        end

        if result.place.to_i > 0
          result.place = result.place.to_i
        elsif result.place.present?
          result.place = result.place.upcase rescue result.place
        elsif row.previous[:place].present? && row.previous[:place].to_i == 0
          result.place = row.previous[:place]
        end

        # USAC format input may contain an age range in the age column for juniors.
        if row[:age].present? && /\d+-\d+/ =~ row[:age].to_s
          result.age = nil
          result.age_group = row[:age]
        end

        result.cleanup
        result.save!
        row.result = result
        Rails.logger.debug("Results::ResultsFile #{Time.zone.now} create result #{race} #{result.place}") if debug?
      else
        # TODO Maybe a hard exception or error would be better?
        Rails.logger.warn("No race. Skip.")
      end
    end
    
    def result_attributes(row, race)
      attributes = row.to_hash.dup
      custom_attributes = {}
      attributes.delete_if do |key, value|
        if race.custom_columns.include?(key.to_s)
          custom_attributes[key] = case value
          when Time
            value.strftime "%H:%M:%S"
          else
            value
          end
          true
        else
          false
        end
      end
      attributes.merge!(:custom_attributes => custom_attributes)
      attributes
    end
    
    def usac_results_format?
      ASSOCIATION.usac_results_format?
    end
    
    def debug?
      ENV["DEBUG_RESULTS"].present? && Rails.logger.debug?
    end

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
          when Spreadsheet::Formula
            value = spreadsheet_row[index].value
          when Spreadsheet::Excel::Error
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
          value = spreadsheet_row[0].value if spreadsheet_row[0].is_a?(Spreadsheet::Formula)
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
end
