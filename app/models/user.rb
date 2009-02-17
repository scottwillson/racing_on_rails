# Admin user
class User < ActiveRecord::Base
  attr_protected :password, :enabled
  
  validates_uniqueness_of :email
  
  validates_confirmation_of :password
  
  validates_length_of :password, :within => 5..40
  validates_length_of :email, :within => 5..128
  
  validates_presence_of :name, :password, :password_confirmation, :email

  def self.authenticate(email, pass)
    find(:first, :conditions => ["email = ? AND password = ?", email, pass])
  end
  
  def email_with_name
    "#{name} <#{email}>"
  end
end
