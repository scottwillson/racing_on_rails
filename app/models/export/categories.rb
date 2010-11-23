module Export
  module Categories
    include Export::Base

    def Category.export
      Category.export_head
      Category.export_data
    end

    private

    def Category.export_head
      Base.export(export_head_sql, "categories.txt")
    end

    def Category.export_data
      Base.export(export_data_sql, "categories.csv")
    end

    def Category.export_head_sql
      "SELECT '#{Category.export_columns.join("','")}'
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY '\\n'"
    end

    def Category.export_data_sql
      "SELECT #{Category.export_columns.join(",")}
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
       LINES TERMINATED BY '\\n'
       FROM categories"
    end

    def Category.export_columns
      [ "id", "parent_id", "name" ]
    end
  end
end
