class RemoveAccountingColumnsFromJoinTable < ActiveRecord::Migration
  def self.up
    change_table :discipline_bar_categories do |t|
      t.remove :lock_version
      t.remove :created_at
      t.remove :updated_at
    end
  end

  def self.down
    change_table :discipline_bar_categories do |t|
      t.integer :lock_version, :default => 0
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end