class AddMemberUsacToToRacers < ActiveRecord::Migration
  def self.up
    add_column :racers, :member_usac_to, :date
  end

  def self.down
    remove_column :racers, :member_usac_to
  end
end
