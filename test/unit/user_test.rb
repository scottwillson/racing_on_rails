require "test_helper"

class UserTest < ActiveSupport::TestCase
  def test_create
    User.create!(:name => 'Mr. Tuxedo', :password =>'blackcat', :password_confirmation =>'blackcat', :email => "tuxedo@example.com")
  end
  
  def test_find_by_info
    assert_equal(users(:promoter), User.find_by_info("Brad ross"))
    assert_equal(users(:promoter), User.find_by_info("Brad ross", "brad@foo.com"))
    assert_equal(users(:administrator), User.find_by_info("Candi Murray"))
    assert_equal(users(:administrator), User.find_by_info("Candi Murray", "admin@example.com", "(503) 555-1212"))
    assert_equal(users(:administrator), User.find_by_info("", "admin@example.com", "(503) 555-1212"))
    assert_equal(users(:administrator), User.find_by_info("", "admin@example.com"))

    assert_nil(User.find_by_info("", "mike_murray@obra.org", "(451) 324-8133"))
    assert_nil(User.find_by_info("", "membership@obra.org"))
    
    promoter = User.new(:name => '', :phone => "(212) 522-1872")
    promoter.save!
    assert_equal(promoter, User.find_by_info("", "", "(212) 522-1872"))
    
    promoter = User.new(:name => '', :email => "cjw@cjw.net")
    promoter.save!
    assert_equal(promoter, User.find_by_info("", "cjw@cjw.net", ""))
  end
  
  def test_save_blank
    User.create!
  end
  
  def test_save_no_name
    User.create!(:email => "nate@six-hobsons.net")
    assert(!User.new(:email => "nate@six-hobsons.net").valid?, "No dupe email addresses allowed")
  end
  
  def test_save_no_email
    User.create!(:name => "Nate Hobson")
    User.create!(:name => "Nate Hobson")
  end
  
  def test_events
    assert(!users(:administrator).events.empty?, 'User Candi should have events')
    assert(User.create(:name => 'New').events.empty?, 'New promoter should not have events')
  end
  
  def test_administrator
    assert(users(:administrator).administrator?, 'administrator administrator?')
    assert(!users(:promoter).administrator?, 'administrator administrator?')
    assert(!users(:member).administrator?, 'administrator administrator?')
    assert(!users(:nate_hobson).administrator?, 'administrator administrator?')
  end
  
  def test_promoter
    assert(users(:administrator).promoter?, 'administrator promoter?')
    assert(users(:promoter).promoter?, 'administrator promoter?')
    assert(!users(:member).promoter?, 'administrator promoter?')
    assert(users(:nate_hobson).promoter?, 'administrator promoter?')
  end
end
