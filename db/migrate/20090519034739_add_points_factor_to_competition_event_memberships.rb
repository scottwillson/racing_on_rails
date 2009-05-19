class AddPointsFactorToCompetitionEventMemberships < ActiveRecord::Migration
  def self.up
    add_column :competition_event_memberships, :points_factor, :float, :default => 1.0
  end

  def self.down
    remove_column :competition_event_memberships, :points_factor
  end
end
