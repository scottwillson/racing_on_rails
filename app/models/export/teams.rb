module Export
  module Teams
    include Export::Base

    def Team.export
      Team.export_head
      Team.export_data
    end

    private

    def Team.export_head
      Base.export(Team.export_head_sql, "teams.txt")
    end

    def Team.export_data
      Base.export(Team.export_data_sql, "teams.csv")
    end

    def Team.export_head_sql
      "SELECT '#{Team.export_columns.join("','")}'
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY '\\n'"
    end

    def Team.export_data_sql
      "SELECT #{Team.export_columns.join(",")}
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
       LINES TERMINATED BY '\\n'
       FROM teams"
    end

    def Team.export_columns
      [
        "id", "name", "city", "state", "website", "contact_name", "contact_email", "contact_phone"
      ]
    end

  end
end
