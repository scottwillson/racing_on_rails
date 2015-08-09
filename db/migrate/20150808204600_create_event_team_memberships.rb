class CreateEventTeamMemberships < ActiveRecord::Migration
  def change
    create_table :event_team_memberships do |t|
      t.references :event, null: false
      t.references :person, null: false
      t.references :team, null: false

      t.timestamps

      t.index :event_id
      t.index :person_id
      t.index :team_id
      t.index [ :event_id, :person_id ], unique: true
    end
  end
end
