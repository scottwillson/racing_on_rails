class DropPersonLockVersion < ActiveRecord::Migration
  def self.up
    remove_column :people, :lock_version
  end

  def self.down
    add_column :people, :lock_version, :integer, :default => 0, :null => false
  end
end
