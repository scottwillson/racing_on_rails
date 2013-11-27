module Export
  module Races
    include Export::Base

    def self.export
      Race.export_head
      Race.export_data
    end

    private

    def self.export_head
      Base.export(export_head_sql, "races.txt")
    end

    def self.export_data
      Base.export(export_data_sql, "races.csv")
    end

    def self.export_head_sql
      "SELECT '#{Race.export_columns.join("','")}'
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY '\\n'"
    end

    def self.export_data_sql
      "SELECT #{Race.export_columns.join(",")}
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
       LINES TERMINATED BY '\\n'
       FROM races"
    end

    def self.export_columns
      [
        "id", "event_id", "category_id", "city", "state", "distance",
        "field_size", "laps", "time", "finishers"
      ]
    end
  end
end
