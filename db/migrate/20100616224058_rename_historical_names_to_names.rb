class RenameHistoricalNamesToNames < ActiveRecord::Migration
  def self.up
    rename_table :historical_names, :names
  end

  def self.down
    rename_table :names, :historical_names
  end
end
