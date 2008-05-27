class AddRacerUpdatedBy < ActiveRecord::Migration
  def self.up
    add_column :racers, :updated_by, :string
  end

  def self.down
    remove_column :racers, :updated_by
  end
end
