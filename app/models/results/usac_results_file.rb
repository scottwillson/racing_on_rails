module Results
  class USACResultsFile < ResultsFile
    def import_row(row, race)
      Rails.logger.debug("Results::ResultsFile #{Time.zone.now} row #{row.spreadsheet_row.to_a.join(', ')}") if debug?

      if race?(row)
        race = find_or_create_race(row)
        # This row is also a result. I.e., no separate race header row.
        create_result row, race
      elsif result?(row)
        create_result row, race
      end

      race
    end

    def race?(row)
      return false if column_indexes.nil? || row.blank?
      return true if row.previous.blank?
      if row[:age].present? && /\d+-\d+/ =~ row[:age].to_s
        return true unless row[:age] == row.previous[:age]
      end
      return false if row[:category_name] == row.previous[:category_name] && row[:gender] == row.previous[:gender] && row[:category_class] == row.previous[:category_class]
      return true
    end

    def new_row(spreadsheet_row, column_indexes)
      Results::USACRow.new spreadsheet_row, column_indexes
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
  end
end
