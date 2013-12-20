module Export
  module Events
    include Export::Base

    def Event.export
      Event.export_head
      Event.export_data
    end

    private

    def Event.export_head
      Base.export(export_head_sql, "events.txt")
    end

    def Event.export_data
      Base.export(export_data_sql, "events.csv")
    end

    def Event.export_head_sql
      "SELECT '#{Event.export_columns.join("','")}'
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY '\\n'"
    end

    def Event.export_data_sql
      "SELECT #{Event.export_columns.join(",")}
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
       LINES TERMINATED BY '\\n'
       FROM events"
    end

    def Event.export_columns
      [
        "id", "parent_id", "name", "discipline", "date", "time",
        "sanctioned_by", "type", "city", "state", "instructional", "practice",
        "postponed", "beginner_friendly", "cancelled"
      ]
    end
  end
end
