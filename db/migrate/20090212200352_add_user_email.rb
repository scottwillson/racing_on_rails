class AddUserEmail < ActiveRecord::Migration
  def self.up
    add_column :users, :email, :string, :limit => 128, :null => false
  end

  def self.down
    remove_column :users, :email
  end
end
