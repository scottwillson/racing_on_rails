class AddEventPostponed < ActiveRecord::Migration
  def self.up
    add_column :events, :postponed, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :events, :postponed
  end
end
