class AddBmxCategory < ActiveRecord::Migration
  def self.up
    add_column :racers, :bmx_category, :string
  end

  def self.down
    remove_column :racers, :bmx_category
  end
end
