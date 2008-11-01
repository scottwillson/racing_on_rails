class AddRacerMailPreferences < ActiveRecord::Migration
  def self.up
    add_column :racers, :wants_email, :boolean, :null => false, :default => true
    add_column :racers, :wants_mail, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :racers, :wants_email
    remove_column :racers, :wants_mail
  end
end
