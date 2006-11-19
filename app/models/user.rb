# Admin user
class User < ActiveRecord::Base
  
  validates_uniqueness_of :username, :on => :create
  validates_confirmation_of :password
  validates_length_of :username, :within => 3..40
  validates_length_of :password, :within => 5..40
  validates_presence_of :name, :username, :password, :password_confirmation

  def self.authenticate(username, pass)
    find_first(["username = ? AND password = ?", username, pass])
  end  
end
