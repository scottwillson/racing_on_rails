class ConvertUserUsernameToEmail < ActiveRecord::Migration
  def self.up
    add_column :users, :email, :string, :limit => 128, :null => false
    @users = User.find(:all)
    @users.each do |user|
      user.update_attribute(:email, user.username)
    end
    remove_column :users, :username
  end

  def self.down
    add_column :users, :username, :string, :null => false
    @users = User.find(:all)
    @users.each do |user|
      user.update_attribute(:username, user.email)
    end
    remove_column :users, :email
  end
end
