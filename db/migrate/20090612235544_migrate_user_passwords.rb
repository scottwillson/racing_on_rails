# authlogic 
class MigrateUserPasswords < ActiveRecord::Migration
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
    User.find(:all).each do |user|
      say "Update password for #{user.old_name}"
      user.password = user.old_password
      user.password_confirmation = user.old_password
      user.save!
    end
    
    change_table :users do |t|
      t.remove :old_password
    end
  end

  # Can't recover passswords!
  def self.down
    change_table :users do |t|
      t.string :password, :null => :false, :default => ""
    end
  end
end
