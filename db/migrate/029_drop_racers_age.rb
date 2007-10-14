class DropRacersAge < ActiveRecord::Migration
  def self.up
    remove_column :racers, :age
  end

  def self.down
  end
end
