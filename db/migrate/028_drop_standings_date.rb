class DropStandingsDate < ActiveRecord::Migration
  def self.up
    remove_column :standings, :date
  end

  def self.down
  end
end
