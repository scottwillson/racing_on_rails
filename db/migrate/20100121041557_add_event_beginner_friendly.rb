class AddEventBeginnerFriendly < ActiveRecord::Migration
  def self.up
    add_column :events, :beginner_friendly, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :events, :Beginner_friendly
  end
end
