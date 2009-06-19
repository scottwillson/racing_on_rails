class UpdateUserForAuthlogic < ActiveRecord::Migration
  class User < ActiveRecord::Base
    acts_as_authentic do |config|
      config.validates_length_of_email_field_options :within => 6..72, :allow_nil => true, :allow_blank => true
      config.validates_format_of_email_field_options :with => Authlogic::Regex.email, 
                                                     :message => I18n.t('error_messages.email_invalid', :default => "should look like an email address."),
                                                     :allow_nil => true,
                                                     :allow_blank => true
      config.validates_length_of_password_field_options  :minimum => 4, :allow_nil => true, :allow_blank => true
      config.validates_length_of_password_confirmation_field_options  :minimum => 4, :allow_nil => true, :allow_blank => true
    end
  end
  
  def self.up
    change_table :users do |t|
      t.rename :password, :old_password
      t.remove :remember_token
      t.remove :remember_token_expires_at
      t.string    :crypted_password, :null => true
      t.string    :password_salt, :null => true
      t.string    :persistence_token, :null => false
      t.string    :single_access_token, :null => true
      t.string    :perishable_token, :null => true
      t.integer   :login_count,         :null => false, :default => 0
      t.integer   :failed_login_count,  :null => false, :default => 0
      t.datetime  :last_request_at
      t.datetime  :current_login_at
      t.datetime  :last_login_at
      t.string    :current_login_ip
      t.string    :last_login_ip
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.change :email, :string, :null => true, :default => nil
      t.rename :name, :old_name
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
      t.remove :first_name
      t.remove :last_name
      t.remove :phone
      t.rename :password, :old_password
      t.string :remember_token, :null => true
      t.datetime :remember_token_expires_at, :null => true
      t.change :email, :string, :null => false, :default => nil
      t.rename :old_name, :name
    end
  end
end
