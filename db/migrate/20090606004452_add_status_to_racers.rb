class AddStatusToRacers < ActiveRecord::Migration
  def self.up
    return if ASSOCIATION.short_name == "MBRA"

    add_column :racers, :status, :string
  end

  def self.down
    remove_column :racers, :status
  end
end
