class UpdateUserForAuthlogic < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.rename :password, :old_password
      t.remove :remember_token
      t.remove :remember_token_expires_at
      t.string    :crypted_password, :null => false
      t.string    :password_salt, :null => false
      t.string    :persistence_token, :null => false
      t.string    :single_access_token, :null => false
      t.string    :perishable_token, :null => false
      t.integer   :login_count,         :null => false, :default => 0
      t.integer   :failed_login_count,  :null => false, :default => 0
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :crypted_password
      t.remove :password_salt
      t.remove :persistence_token
      t.remove :single_access_token
      t.remove :perishable_token
      t.remove :login_count
      t.remove :failed_login_count
      t.remove :last_request_at
      t.remove :current_login_at
      t.remove :last_login_at
      t.remove :current_login_ip
      t.remove :last_login_ip
      t.rename :password, :old_password
      t.string :remember_token, :null => true
      t.datetime :remember_token_expires_at, :null => true
    end
  end
end
