class AddUserRememberTokens < ActiveRecord::Migration
  def self.up
    add_column :users, :remember_token, :string, :limit => 40
    add_column :users, :remember_token_expires_at, :datetime
  end

  def self.down
    remove_column :users, :remember_token_expires_at
    remove_column :users, :remember_token
  end
end
