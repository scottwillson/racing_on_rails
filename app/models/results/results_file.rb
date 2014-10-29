module Results
  # Import Excel results file
  #
  # Result time limited to hundredths of seconds
  #
  # Notes example:
  # Senior Men Pro/1/2 | Field size: 79 riders | Laps: 2
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

    attr_accessor :import_warnings

    COLUMN_MAP = {
      "placing"           => "place",
      ";place"            => "place",
      "pl"                => "place",
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
      "race_category"     => "category_name",
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
      "bib"               => "number",
      "bib_#"             => "number",
      "obra_number"       => "number",
      "oregoncup"         => "oregon_cup",
      "membership_#"      => "license",
      "membership"        => "license",
      "license_#"         => "license",
      "team/club"         => "team_name",
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
      "total_points"      => "points_total",
      "sex"               => "gender"
    }

    def initialize(source, event)
      self.column_indexes = nil
      self.event = event
      self.custom_columns = Set.new
      self.race_custom_columns = Set.new
      self.import_warnings = Set.new
      self.source = source
    end

    # See http://racingonrails.rocketsurgeryllc.com/sample_import_files/ for format details and examples.
    def import
      ActiveSupport::Notifications.instrument "import.results_file.racing_on_rails", source: source.try(:path) do
        Event.transaction do
          book = ::Spreadsheet.open(source.path)
          book.worksheets.each do |worksheet|
            race = nil

            create_rows(worksheet)
            ActiveSupport::Notifications.instrument "worksheet.import.results_file.racing_on_rails", rows: rows.size

            rows.each do |row|
              race = import_row(row, race)
            end
          end
        end

        if import_warnings.to_a.size > 10
          self.import_warnings = import_warnings.to_a[0, 10]
        end
      end

      ActiveSupport::Notifications.instrument "warnings.import.results_file.racing_on_rails", warnings_count: import_warnings.to_a.size
    end

    def import_row(row, race)
      Rails.logger.debug("Results::ResultsFile #{Time.zone.now} row #{row.spreadsheet_row.to_a.join(', ')}") if debug?

      if race?(row)
        race = find_or_create_race(row)
      elsif result?(row)
        create_result row, race
      end

      race
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
            Rails.logger.debug("number_format pattern to_s to_f #{spreadsheet_row.format(index).number_format}  #{spreadsheet_row.format(index).pattern} #{cell} #{cell.to_f if cell.respond_to?(:to_f)} #{cell.class}")
          end
        end
        row = Results::Row.new(spreadsheet_row, column_indexes)
        row = new_row(spreadsheet_row, column_indexes)
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
    # { place: 0, number: 1, first_name: 2 }
    def create_columns(spreadsheet_row)
      self.column_indexes = Hash.new
      self.columns = []

      spreadsheet_row.each_with_index do |cell, index|
        Rails.logger.debug("CELLS: #{cell.to_s}, #{spreadsheet_row[index - 1].blank?}, #{spreadsheet_row[index + 1].blank?}") if debug?

        cell_string = cell.to_s
        cell_string = strip_quotes(cell_string)

        if cell_string == "Name" && spreadsheet_row[index + 1].blank?
          cell_string = "First Name"
        elsif cell_string.blank? && "Name" == spreadsheet_row[index - 1]
          cell_string = "Last Name"
        end

        if index == 0 && cell_string.blank?
          column_indexes[:place] = 0
        elsif cell_string.present?
          column_name = to_column_name(cell_string)

          create_column column_name, index
        end
      end

      Rails.logger.debug("Results::ResultsFile #{Time.zone.now} Create column indexes #{self.column_indexes.inspect}") if debug?
      self.column_indexes
    end

    def race?(row)
      return false if column_indexes.nil? || row.last? || row.blank? || (row.next && row.next.blank?)
      return false if row.place && row.place.to_i != 0
      row.next && row.next.place && row.next.place.to_i == 1
    end

    def find_or_create_race(row)
      category = Category.find_or_create_by_normalized_name(category_name_from_row(row))
      race = event.races.detect { |r| r.category == category }
      if race
        race.results.clear
      else
        race = event.races.build(category: category, notes: row.notes)
      end
      race.result_columns = columns
      race.custom_columns = race_custom_columns.to_a
      race.save!

      ActiveSupport::Notifications.instrument "find_or_create_race.import.results_file.racing_on_rails", race_name: race.name, race_id: race.id

      race
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
      if race.nil?
        Rails.logger.warn "No race. Skipping result file row."
        return nil
      end

      result = race.results.build(result_methods(row, race))
      result.updated_by = @event.name

      if row.same_time?
        result.time = row.previous.result.time
      end

      set_place result, row
      set_age_group result, row

      result.cleanup
      result.save!
      row.result = result
      Rails.logger.debug("Results::ResultsFile #{Time.zone.now} create result #{race} #{result.place}") if debug?

      result
    end

    def result_methods(row, race)
      attributes = row.to_hash.dup
      custom_attributes = {}
      attributes.delete_if do |key, value|
        _key = key.to_s.to_sym
        if race.custom_columns.include?(_key)
          custom_attributes[_key] = case value
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
      attributes.merge! custom_attributes: custom_attributes
      attributes
    end

    def prototype_result
      @prototype_result ||= Result.new.freeze
    end

    def debug?
      ENV["DEBUG_RESULTS"].present? && Rails.logger.debug?
    end


    private

    def new_row(spreadsheet_row, column_indexes)
      Results::Row.new spreadsheet_row, column_indexes
    end

    def category_name_from_row(row)
      row.first
    end

    def strip_quotes(string)
      if string.present?
        string = string.strip
        string = string.gsub(/^"/, '')
        string = string.gsub(/"$/, '')
      end
      string
    end

    def set_place(result, row)
      if result.numeric_place?
        result.place = result.numeric_place
        if race?(row) && result.place != 1
          self.import_warnings << "First racer #{row[:first_name]} #{row[:last_name]} should be first place racer. "
          # if we have a previous rov and the current place is not one more than the previous place, then sequence error.
        elsif !race?(row) && row.previous && row.previous[:place].present? && row.previous[:place].to_i != (result.place - 1)
          self.import_warnings << "Non-sequential placings detected for racer: #{row[:first_name]} #{row[:last_name]}. " unless row[:category_name].to_s.downcase.include?("tandem") # or event is TTT or ???
        end
      elsif result.place.present?
        result.place = result.place.upcase
      elsif row.previous[:place].present? && row.previous[:place].to_i == 0
        result.place = row.previous[:place]
      end
    end

    # USAC format input may contain an age range in the age column for juniors.
    def set_age_group(result, row)
      if row[:age].present? && /\d+-\d+/ =~ row[:age].to_s
        result.age = nil
        result.age_group = row[:age]
      end
      result
    end

    def to_column_name(cell)
      cell = cell.downcase.
                  underscore.
                  gsub(" ", "_")

      if COLUMN_MAP[cell]
        COLUMN_MAP[cell]
      else
        cell
      end
    end

    def create_column(name, index)
      return if name.blank?

      column_indexes[name.to_sym] = index
      columns << name
      if !result_method?(name)
        custom_columns << name
        race_custom_columns << name
      end
    end

    def result_method?(column_name)
      prototype_result.respond_to?(column_name.to_sym)
    end
  end
end
