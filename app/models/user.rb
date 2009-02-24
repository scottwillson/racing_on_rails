# Admin user
class User < ActiveRecord::Base
  attr_protected :password, :enabled
  
  validates_uniqueness_of :email
  
  validates_confirmation_of :password
  
  validates_length_of :password, :within => 5..40
  validates_length_of :email, :within => 5..128
  
  validates_presence_of :name, :password, :password_confirmation, :email
  
  has_and_belongs_to_many :roles

  def self.authenticate(email, pass)
    find(:first, :conditions => ["email = ? AND password = ?", email, pass])
  end
  
  def self.secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def self.make_token
    secure_digest(Time.now, (1..10).map{ rand.to_s })
  end

  def remember_token?
    (!remember_token.blank?) && 
      remember_token_expires_at && (Time.now.utc < remember_token_expires_at.utc)
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = self.class.make_token
    save(false)
  end

  # refresh token (keeping same expires_at) if it exists
  def refresh_token
    if remember_token?
      self.remember_token = self.class.make_token 
      save(false)      
    end
  end

  # 
  # Deletes the server-side record of the authentication token.  The
  # client-side (browser cookie) and server-side (this remember_token) must
  # always be deleted together.
  #
  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def email_with_name
    "#{name} <#{email}>"
  end
  
  def has_role?(rolename)
    self.roles.find_by_name(rolename) ? true : false
  end
end
