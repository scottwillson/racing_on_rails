class AddPersonOfficial < ActiveRecord::Migration
  def self.up
    add_column :people, :official, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :people, :official
  end
end
