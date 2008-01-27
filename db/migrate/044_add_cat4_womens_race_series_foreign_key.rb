class AddCat4WomensRaceSeriesForeignKey < ActiveRecord::Migration
  def self.up
    add_column :events, :cat4_womens_race_series_id, :integer, :references => :events, :on_delete => :set_null
  end

  def self.down
    remove_column :events, :cat4_womens_race_series_id
  end
end
