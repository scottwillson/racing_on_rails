module Export
  module Categories
    include Export::Base

    def self.export
      Category.export_head
      Category.export_data
    end

    private

    def self.export_head
      Base.export(export_head_sql, "categories.txt")
    end

    def self.export_data
      Base.export(export_data_sql, "categories.csv")
    end

    def self.export_head_sql
      "SELECT '#{Category.export_columns.join("','")}'
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY '\\n'"
    end

    def self.export_data_sql
      "SELECT #{Category.export_columns.join(",")}
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
       LINES TERMINATED BY '\\n'
       FROM categories"
    end

    def self.export_columns
      [ "id", "parent_id", "name" ]
    end
  end
end
