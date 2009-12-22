class AddPersonMembershipInfo < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.string :license_type, :default => nil, :null => true
      t.string :country, :default => nil, :null => true
    end
  end

  def self.down
    change_table :people do |t|
      t.remove :license_type
      t.remove :country
    end
  end
end
