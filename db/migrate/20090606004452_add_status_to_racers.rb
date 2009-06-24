class AddStatusToRacers < ActiveRecord::Migration
  def self.up
    return if ASSOCIATION.short_name == "MBRA"

    add_column :people, :status, :string
  end

  def self.down
    remove_column :people, :status
  end
end
