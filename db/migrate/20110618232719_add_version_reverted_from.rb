class AddVersionRevertedFrom < ActiveRecord::Migration
  def self.up
    change_table :versions do |t|
      t.integer :reverted_from
    end
  end

  def self.down
    change_table :versions do |t|
      t.drop :reverted_from
    end
  end
end