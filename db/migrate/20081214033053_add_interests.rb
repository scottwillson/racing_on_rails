class AddInterests < ActiveRecord::Migration
  def self.up
    add_column :racers, :volunteer_interest, :boolean, :default => false, :null => false
    add_column :racers, :official_interest, :boolean, :default => false, :null => false
    add_column :racers, :race_promotion_interest, :boolean, :default => false, :null => false
    add_column :racers, :team_interest, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :racers, :team_interest
    remove_column :racers, :race_promotion_interest
    remove_column :racers, :official_interest
    remove_column :racers, :volunteer_interest
  end
end
