class MoveWeeksOfEventsToHome < ActiveRecord::Migration
  def change
    change_table :homes do |t|
      t.integer :weeks_of_recent_results, default: 2, null: false
      t.integer :weeks_of_upcoming_events, default: 2, null: false
    end
    
    home = Home.current
    home.weeks_of_recent_results = RacingAssociation.current.weeks_of_recent_results
    home.weeks_of_upcoming_events = RacingAssociation.current.weeks_of_upcoming_events
    home.save!
    
    remove_column :racing_associations, :weeks_of_recent_results
    remove_column :racing_associations, :weeks_of_upcoming_events
  end
end
