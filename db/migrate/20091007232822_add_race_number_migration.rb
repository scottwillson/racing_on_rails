class AddRaceNumberMigration < ActiveRecord::Migration
  def self.up
    add_index :race_numbers, :year
  end

  def self.down
    remove_index :race_numbers, :year
  end
end
