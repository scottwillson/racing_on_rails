module Export
  module Events
    include Export::Base

    def self.export
      Event.export_head
      Event.export_data
    end

    private

    def self.export_head
      Base.export(export_head_sql, "events.txt")
    end

    def self.export_data
      Base.export(export_data_sql, "events.csv")
    end

    def self.export_head_sql
      "SELECT '#{Event.export_columns.join("','")}'
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY '\\n'"
    end

    def self.export_data_sql
      "SELECT #{Event.export_columns.join(",")}
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
       LINES TERMINATED BY '\\n'
       FROM events"
    end

    def self.export_columns
      [
        "id", "parent_id", "name", "discipline", "date", "time",
        "sanctioned_by", "type", "city", "state", "instructional", "practice",
        "postponed", "beginner_friendly", "cancelled"
      ]
    end
  end
end
