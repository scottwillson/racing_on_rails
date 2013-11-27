module Export
  module Aliases
    include Export::Base

    def self.export
      Alias.export_head
      Alias.export_data
    end

    private

    def self.export_head
      Base.export(Alias.export_head_sql, "aliases.txt")
    end

    def self.export_data
      Base.export(Alias.export_data_sql, "aliases.csv")
    end

    def self.export_head_sql
      "SELECT '#{Alias.export_columns.join("','")}'
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY '\\n'"
    end

    def self.export_data_sql
      "SELECT #{Alias.export_columns.join(",")}
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
       LINES TERMINATED BY '\\n'
       FROM aliases"
    end

    def self.export_columns
      [
        "id", "alias", "name", "person_id", "team_id"
      ]
    end

  end
end
