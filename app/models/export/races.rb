module Export
  module Races
    include Export::Base

    def Race.export
      Race.export_head
      Race.export_data
    end

    private

    def Race.export_head
      Base.export(export_head_sql, "races.txt")
    end

    def Race.export_data
      Base.export(export_data_sql, "races.csv")
    end

    def Race.export_head_sql
      "SELECT '#{Race.export_columns.join("','")}'
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY '\\n'"
    end

    def Race.export_data_sql
      "SELECT #{Race.export_columns.join(",")}
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
       LINES TERMINATED BY '\\n'
       FROM races"
    end

    def Race.export_columns
      [
        "id", "event_id", "category_id", "city", "state", "distance",
        "field_size", "laps", "time", "finishers"
      ]
    end
  end
end
