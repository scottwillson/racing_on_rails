class AddEventRegistrationPublic < ActiveRecord::Migration
  def up
    if RacingAssociation.current.short_name == "OBRA"
      add_column :events, :registration_public, :boolean, default: true, null: false
    end
  end

  def down
    remove_column(:events, :registration_public) rescue nil
  end
end