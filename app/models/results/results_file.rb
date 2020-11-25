# frozen_string_literal: true

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
    attr_accessor :event
    attr_accessor :source
    attr_accessor :custom_columns
    attr_accessor :import_warnings

    def self.same_time?(row)
      return false unless row.previous
      return true if row[:time].blank?

      if row[:time].present?
        row_time = row[:time].try(:to_s)
        row_time && (row_time[/st/i] || row_time[/s\.t\./i])
      end
    end

    def initialize(source, event)
      self.event = event
      self.custom_columns = Set.new
      self.import_warnings = Set.new
      self.source = source
    end

    # See http://racingonrails.rocketsurgeryllc.com/sample_import_files/ for format details and examples.
    def import
      ActiveSupport::Notifications.instrument "import.results_file.racing_on_rails", source: source.try(:path) do
        Event.transaction do
          race = nil
          table = Tabular::Table.new
          table.column_mapper = Results::ColumnMapper.new
          table.read source
          table.delete_blank_columns!
          table.delete_blank_rows!

          add_custom_columns table
          assert_columns! table

          table.rows.each do |row|
            race = import_row(row, race, table.columns.map(&:key))
          end

          @event.update_split_from!
        end

        import_warnings.to_a.take(10)
      end

      ActiveSupport::Notifications.instrument "warnings.import.results_file.racing_on_rails", warnings_count: import_warnings.to_a.size
    end

    def import_row(row, race, columns)
      Rails.logger.debug("Results::ResultsFile #{Time.zone.now} row #{row.to_hash}") if debug?
      if race?(row)
        race = find_or_create_race(row, columns)
      elsif result?(row)
        create_result row, race
      end

      race
    end

    def race?(row)
      return false if row.last?
      # Won't correctly detect races that only have DQs or DNSs
      row.next &&
        category_name_from_row(row).present? &&
        !row[:place].to_s[/\A1\z/] &&
        !row[:place].to_s[/\A1.0\z/] &&
        !row[:place].to_s.upcase.in?(%w[ DNS DQ DNF]) &&
        row.next[:place] &&
        row.next[:place].to_i == 1 &&
        (row.previous.nil? || row.previous[:place].blank? || result?(row.previous))
    end

    def find_or_create_race(row, columns)
      category = Category.find_or_create_by_normalized_name(category_name_from_row(row))
      race = event.races.detect { |r| r.category == category }
      if race
        race.results.clear
        race.update! visible: true, custom_columns: custom_columns.to_a
      else
        race = event.races.build(category: category, notes: notes(row), custom_columns: custom_columns.to_a)
      end
      race.result_columns = columns.map(&:to_s)
      race.save!

      ActiveSupport::Notifications.instrument "find_or_create_race.import.results_file.racing_on_rails", race_name: race.name, race_id: race.id

      race
    end

    def result?(row)
      return false unless row
      return true if row[:place].present? || row[:number].present? || row[:license].present? || row[:team_name].present?
      return true unless row[:first_name].blank? && row[:last_name].blank? && row[:name].blank?
      false
    end

    def create_result(row, race)
      if race.nil?
        Rails.logger.warn "No race. Skipping result file row."
        return nil
      end

      result = race.results.build(result_methods(row, race))
      result.updater = @event.name

      result.time = race.results[race.results.size - 2].time if Results::ResultsFile.same_time?(row)

      set_place result, row
      set_age_group result, row

      result.cleanup
      result.save!
      Rails.logger.debug("Results::ResultsFile #{Time.zone.now} create result #{race} #{result.place}") if debug?

      result
    end

    def result_methods(row, _race)
      attributes = row.to_hash.dup
      custom_attributes = {}
      attributes.delete_if do |key, value|
        _key = key.to_s.to_sym
        if custom_columns.include?(_key)
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
      attributes[:custom_attributes] = custom_attributes
      attributes
    end

    def prototype_result
      @prototype_result ||= Result.new.freeze
    end

    def debug?
      ENV["DEBUG_RESULTS"].present? && Rails.logger.debug?
    end

    private

    def category_name_from_row(row)
      row.first
    end

    def notes(row)
      if row[:notes].present?
        row[:notes]
      else
        cells = row.to_a
        cells[1, cells.size].select(&:present?).join(", ")
      end
    end

    def strip_quotes(string)
      if string.present?
        string = string.strip
        string = string.gsub(/^"/, "")
        string = string.gsub(/"$/, "")
      end
      string
    end

    def set_place(result, row)
      if result.numeric_place?
        result.place = result.numeric_place
        if race?(row) && result.place != 1
          import_warnings << "First racer #{row[:first_name]} #{row[:last_name]} should be first place racer. "
          # if we have a previous rov and the current place is not one more than the previous place, then sequence error.
        elsif !race?(row) &&
              row.previous &&
              row.previous[:place].present? &&
              row.previous[:place].to_i != result.numeric_place &&
              row.previous[:place].to_i != (result.numeric_place - 1)
          import_warnings << "Non-sequential placings detected for racer: #{row.previous[:place]} #{row[:first_name]} #{row[:last_name]}. " unless row[:category_name].to_s.downcase.include?("tandem") # or event is TTT or ???
        end
      elsif result.place.present?
        result.place = result.place.to_s.upcase
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
      cell = cell.downcase
                 .underscore
                 .tr(" ", "_")

      if COLUMN_MAP[cell]
        COLUMN_MAP[cell]
      else
        cell
      end
    end

    def add_custom_columns(table)
      table.columns.each do |column|
        custom_columns << column.key if column.key && !result_method?(column.key)
      end
    end

    def result_method?(column_name)
      column_name.to_sym != :discipline && prototype_result.respond_to?(column_name.to_sym)
    end

    def assert_columns!(table)
      keys = table.columns.map(&:key)
      import_warnings << "No place column. Place is required." unless keys.include?(:place)

      unless keys.include?(:name) || (keys.include?(:first_name) && keys.include?(:lastname)) || keys.include?(:team_name)
        import_warnings << "No name column. Name, first name, last name or team name is required."
      end
    end
  end
end
