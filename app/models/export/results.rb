module Export
  module Results
    include Export::Base

    def self.export
      Result.export_head
      Result.export_data
    end

    private

    def self.export_head
      Base.export(Result.export_head_sql, "results.txt")
    end

    def self.export_data
      Base.export(Result.export_data_sql, "results.csv")
    end

    def self.export_head_sql
      "SELECT '#{Result.export_columns.join("','")}'
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY '\\n'"
    end

    def self.export_data_sql
      "SELECT #{Result.export_columns(true).join(",")}
       INTO OUTFILE '%s'
       FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '\"'
       LINES TERMINATED BY '\\n'
       FROM results
       LEFT JOIN people ON results.person_id=people.id"
    end

    def self.export_columns(fully_qualified = false)
      if fully_qualified
        columns = []
        Result.export_columns_for_results.each do |column|
          columns << "results." + column
        end
        Result.export_columns_for_people.each do |column|
          columns << "people." + column
        end
        columns
      else
        Result.export_columns_for_results + Result.export_columns_for_people
      end
    end

    def self.export_columns_for_results
      [
        "id", "category_id", "person_id", "race_id", "team_id", "age",
        "age_group", "date_of_birth", "gender", "license", "number", "city",
        "state", "category_class", "place", "place_in_category", "points",
        "points_from_place", "points_bonus", "points_penalty",
        "points_bonus_penalty", "points_total", "time", "time_bonus_penalty",
        "time_gap_to_leader", "time_gap_to_previous", "time_gap_to_winner",
        "time_total", "laps", "is_series", "preliminary"
      ]
    end

    def self.export_columns_for_people
      [ "first_name", "last_name" ]
    end
  end
end
