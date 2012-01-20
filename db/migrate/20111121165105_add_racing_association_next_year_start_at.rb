class AddRacingAssociationNextYearStartAt < ActiveRecord::Migration
  def self.up
    change_table :racing_associations do |t|
      t.date :next_year_start_at
    end
  end

  def self.down
    change_table :racing_associations do |t|
      t.remove :next_year_start_at
    end
  end
end