# authlogic 
class MigrateUserPasswords < ActiveRecord::Migration
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
