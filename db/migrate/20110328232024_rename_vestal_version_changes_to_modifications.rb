class RenameVestalVersionChangesToModifications < ActiveRecord::Migration
  def self.up
    change_table :versions do |t|
      t.rename :changes, :modifications
    end
  end

  def self.down
    change_table :versions do |t|
      t.rename :modifications, :changes
    end
  end
end