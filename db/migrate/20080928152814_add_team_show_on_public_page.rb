class AddTeamShowOnPublicPage < ActiveRecord::Migration
  def self.up
    add_column :teams, :show_on_public_page, :boolean, :default => false
  end

  def self.down
    remove_column :teams, :show_on_public_page
  end
end
