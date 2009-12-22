class AddPersonMembershipCard < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.boolean :membership_card, :default => false, :null => false
    end
  end

  def self.down
    change_table :people do |t|
      t.remove :membership_card
    end
  end
end
