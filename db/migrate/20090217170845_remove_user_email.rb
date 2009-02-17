class RemoveUserEmail < ActiveRecord::Migration
  def self.up
    remove_column :users, :email
  end

  def self.down
    add_column :users, :email, :string, :limit => 128, :null => false
  end
end
