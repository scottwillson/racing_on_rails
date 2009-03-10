class AddEventsAtraPointsSeries < ActiveRecord::Migration
  def self.up
    add_column :events, :atra_points_series, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :events, :atra_points_series
  end
end
