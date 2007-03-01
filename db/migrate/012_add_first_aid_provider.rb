class AddFirstAidProvider < ActiveRecord::Migration
  def self.up
    add_column(:events, :first_aid_provider, :string, :null => false, :default => 'Needed')
  end

  def self.down
    remove_column(:events, :first_aid_provider)
  end
end
