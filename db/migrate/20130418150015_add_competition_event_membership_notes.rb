class AddCompetitionEventMembershipNotes < ActiveRecord::Migration
  def change
    add_column :competition_event_memberships, :notes, :string
  end
end
