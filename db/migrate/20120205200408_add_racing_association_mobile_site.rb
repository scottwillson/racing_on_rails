class AddRacingAssociationMobileSite < ActiveRecord::Migration
  def self.up
    add_column :racing_associations, :mobile_site, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :racing_associations, :mobile_site
  end
end
