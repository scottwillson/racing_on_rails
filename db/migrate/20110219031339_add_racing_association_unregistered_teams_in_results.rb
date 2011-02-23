class AddRacingAssociationUnregisteredTeamsInResults < ActiveRecord::Migration
  def self.up
    change_table :racing_associations do |t|
      t.boolean :unregistered_teams_in_results, :default => true, :null => false
    end
    
    racing_asssociation = RacingAssociation.current
    if racing_asssociation.short_name == "OBRA"
      racing_asssociation.update_attribute :unregistered_teams_in_results, false
    end
  end

  def self.down
    change_table :racing_associations do |t|
      t.remove :unregistered_teams_in_results
    end
  end
end
