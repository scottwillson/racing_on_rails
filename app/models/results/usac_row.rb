module Results
  class USACRow < Results::Row
    def notes
      # We want to pick up the info in the first 5 columns: org, year, event #, date, discipline
      return "" if blank? || size < 5
      spreadsheet_row[0, 5].select { |cell| cell.present? }.join(", ")
    end
  end
end
