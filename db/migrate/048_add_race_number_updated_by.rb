class AddRaceNumberUpdatedBy < ActiveRecord::Migration
  def self.up
    add_column :race_numbers, :updated_by, :string
  end

  def self.down
    remove_column :race_numbers, :updated_by
  end
end
