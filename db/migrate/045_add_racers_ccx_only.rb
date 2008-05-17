class AddRacersCcxOnly < ActiveRecord::Migration
  def self.up
    add_column :racers, :ccx_only, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :racers, :ccx_only
  end
end
