class AddWebsiteRegistrationToEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :website, :string
    add_column :events, :registration_link, :string
  end

  def self.down
    remove_column :events, :registration_link
    remove_column :events, :website
  end
end
