class AddMoreTeamFields < ActiveRecord::Migration
  def self.up
    add_column :teams, :website, :string
    add_column :teams, :sponsors, :string, :limit => 1000
    add_column :teams, :contact_name, :string
    add_column :teams, :contact_email, :string
    add_column :teams, :contact_phone, :string
  end

  def self.down
    remove_column :teams, :contact_phone
    remove_column :teams, :contact_email
    remove_column :teams, :contact_name
    remove_column :teams, :sponsors
    remove_column :teams, :website
  end
end
