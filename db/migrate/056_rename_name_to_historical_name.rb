class RenameNameToHistoricalName < ActiveRecord::Migration
  def self.up
    rename_table :names, :historical_names
    add_column :historical_names, :lock_version, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :historical_names, :lock_version
    rename_table :historical_names, :names
  end
end
