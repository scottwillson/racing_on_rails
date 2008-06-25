class AddAutoCombinedStandings < ActiveRecord::Migration
  def self.up
    add_column :standings, :auto_combined_standings, :boolean, :default => true
  end

  def self.down
    remove_column :standings, :auto_combined_standings
  end
end
