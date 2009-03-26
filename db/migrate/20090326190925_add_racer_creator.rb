class AddRacerCreator < ActiveRecord::Migration
  def self.up
    add_column :racers, :created_by_id, :integer
    add_column :racers, :created_by_type, :string
  end

  def self.down
    remove_column :racers, :created_by_type
    remove_column :racers, :created_by_id
  end
end
