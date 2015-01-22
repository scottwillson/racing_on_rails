module Results
  class USACResultsFile < ResultsFile
    def import_row(row, race, columns)
      Rails.logger.debug("Results::ResultsFile #{Time.zone.now} row #{row.to_hash}") if debug?
      if race?(row)
        race = find_or_create_race(row, columns)
        # This row is also a result. I.e., no separate race header row.
        create_result row, race
      elsif result?(row)
        create_result row, race
      end

      race
    end

    def race?(row)
      return true if row.previous.nil?

      # Won't correctly detect races that only have DQs or DNSs
      category_name_from_row(row).present? &&
      category_name_from_row(row) != category_name_from_row(row.previous) &&
      !row[:place].to_s.upcase.in?(%w{ DNS DQ DNF}) &&
      row[:place] &&
      row[:place].to_i == 1
    end

    def new_row(spreadsheet_row, column_indexes)
      Results::Row.new spreadsheet_row, column_indexes
    end

    # category_name and gender should always be populated.
    # juniors, and conceivably masters, may be split by age group in which case the age column should
    # contain the age range. otherwise it may be empty or contain an individual racer's age.
    # The end result should look like "Junior Women 13-14" or "Junior Men"
    # category_class may or may not be populated
    # e.g. "Master B Men" or "Cat4 Female"
    def category_name_from_row(row)
      category = "#{row[:category_name]} #{row[:category_class]} #{row[:gender]}"
      if row[:age].present? && /\d+-\d+/ =~ row[:age].to_s
        category = "#{category} #{row[:age]}"
      end
      category.squeeze(" ").strip
    end

    def create_column(name, index)
      return if name.blank?

      if result_method?(name)
        column_indexes[name.to_sym] = index
        columns << name
      end
    end

    # We want to pick up the info in the first 5 columns: org, year, event #, date, discipline
    def notes(row)
      [ :organization, :event_year, :"event_#", :race_date, :discipline ].
      map { |column| row[column] }.
      select(&:present?).
      map { |x| to_integer(x) }.
      join(", ")
    end


    private

    def to_integer(value)
      if value.respond_to?(:to_i) && value.to_i > 0
        value.to_i
      else
        value
      end
    end
  end
end
