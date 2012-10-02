class AddRacingAssociationFilterScheduleBySanctioningOrganization < ActiveRecord::Migration
  def change
    add_column :racing_associations, :filter_schedule_by_sanctioning_organization, :boolean, :default => false, :null => false
  end
end
