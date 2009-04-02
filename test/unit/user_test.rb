require "test_helper"

class UserTest < ActiveSupport::TestCase
  
  def test_create
    User.create!(:name => 'Mr. Tuxedo', :password =>'blackcat', :password_confirmation =>'blackcat', :email => "tuxedo@example.com")
  end
end
