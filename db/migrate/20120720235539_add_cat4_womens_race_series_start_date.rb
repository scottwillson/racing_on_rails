class AddCat4WomensRaceSeriesStartDate < ActiveRecord::Migration
  def self.up
    add_column :racing_associations, :cat4_womens_race_series_start_date, :date
  end

  def self.down
    remove_column :racing_associations, :cat4_womens_race_series_start_date
  end
end