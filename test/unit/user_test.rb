require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  
  def test_create
    User.create(:username => 'tuxedo', :name => 'Mr. Tuxedo', :password =>'cat')
  end
end
