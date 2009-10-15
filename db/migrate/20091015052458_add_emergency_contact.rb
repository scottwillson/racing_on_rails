class AddEmergencyContact < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.string :emergency_contact
      t.string :emergency_contact_phone
    end
  end

  def self.down
    change_table :people do |t|
      t.remove :emergency_contact
      t.remove :emergency_contact_phone
    end
  end
end
