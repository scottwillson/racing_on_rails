# Admin user
class User < ActiveRecord::Base
  attr_protected :password, :enabled
  
  validates_uniqueness_of :username, :on => :create
  validates_uniqueness_of :email
  
  validates_confirmation_of :password
  
  validates_length_of :username, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_length_of :email, :within => 5..128
  
  validates_presence_of :name, :username, :password, :password_confirmation, :email

  def self.authenticate(username, pass)
    find(:first, :conditions => ["username = ? AND password = ?", username, pass])
  end
  
  def email_with_name
    "#{name} <#{email}>"
  end
end
