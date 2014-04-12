# coding: utf-8

require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class LoginTest < ActionController::TestCase
  tests PeopleController

  def test_create_login
    ActionMailer::Base.deliveries.clear
    
    use_ssl
    post :create_login, 
         :person => { 
           :login => "racer@example.com", 
           :password => "secret", 
           :password_confirmation => "secret", 
           :email => "racer@example.com"
          },
         :return_to => root_path
    assert_redirected_to root_path
    
    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
  end

  def test_create_login_with_token
    ActionMailer::Base.deliveries.clear
    
    person = FactoryGirl.create(:person)
    person.reset_perishable_token!
    use_ssl
    post :create_login, 
         :person => { 
           :login => "racer@example.com", 
           :password => "secret", 
           :password_confirmation => "secret",
           :email => "racer@example.com"
          },
         :id => person.perishable_token
    assert_redirected_to edit_person_path(person)
    
    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
  end

  def test_create_login_with_name
    ActionMailer::Base.deliveries.clear
    
    use_ssl
    post :create_login, 
         :person => { 
           :login => "racer@example.com", 
           :name => "Bike Racer",
           :password => "secret", 
           :password_confirmation => "secret", 
           :email => "racer@example.com"
          },
         :return_to => root_path
    assert_redirected_to root_path
    
    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
  end

  def test_create_login_with_license_and_name
    ActionMailer::Base.deliveries.clear
    existing_person = Person.create!(:license => "123", :name => "Speed Racer")
    
    use_ssl
    post :create_login, 
         :person => { :login => "racer@example.com", 
                      :password => "secret", 
                      :password_confirmation => "secret", 
                      :email => "racer@example.com", 
                      :license => "123   ",
                      :name => "    Speed Racer"
                    },
         :return_to => root_path
 
    assert assigns(:person).errors.empty?, "Should not have errors, but had: #{assigns(:person).errors.full_messages}"
    assert_redirected_to root_path
    
    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
    assert_equal existing_person, assigns(:person), "Should match existing Person"
  end
  
  def test_create_login_with_license_in_name_field
    ActionMailer::Base.deliveries.clear
     existing_person = Person.create!(:license => "123", :name => "Speed Racer")
    
    use_ssl
    post :create_login, 
         :person => { :login => "racer@example.com", 
                      :password => "secret", 
                      :password_confirmation => "secret", 
                      :email => "racer@example.com", 
                      :license => "Speed Racer",
                      :name => ""
                    },
         :return_to => root_path
 
    assert_response :success
    assert assigns(:person).errors[:name].present?, "Should have error on :name"
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end
  
  def test_create_login_with_reversed_fields
    ActionMailer::Base.deliveries.clear
    existing_person = Person.create!(:license => "123", :name => "Speed Racer")
    
    use_ssl
    post :create_login, 
         :person => { :login => "racer@example.com", 
                      :password => "secret", 
                      :password_confirmation => "secret", 
                      :email => "racer@example.com", 
                      :license => "Speed Racer",
                      :name => "123"
                    },
         :return_to => root_path
 
    assert_response :success
    assert assigns(:person).errors.any?, "Should have errors"
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end
  
  def test_create_login_blank_license
    ActionMailer::Base.deliveries.clear
    people_count = Person.count
    
    use_ssl
    post :create_login, 
         :person => { :login => "racer@example.com", :email => "racer@example.com", :password => "secret", 
                      :password_confirmation => "secret", :license => "" },
         :return_to => root_path
    assert_redirected_to root_path
    
    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
    assert_equal people_count + 1, Person.count, "People count. Should add one."
  end
  
  def test_create_login_no_email
    ActionMailer::Base.deliveries.clear
    
    Person.create! :license => "111", :email => "racer@example.com"
    
    use_ssl
    post :create_login, 
         :person => { :login => "racer@example.com", 
                      :password => "secret", 
                      :password_confirmation => "secret", 
                      :email => "" 
                    },
         :return_to => root_path

    assert_response :success
    assert assigns(:person).errors[:email].present?, "Should have error on :email"
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end
  
  def test_create_dupe_login_no_email
    ActionMailer::Base.deliveries.clear
    
    use_ssl
    post :create_login, 
         :person => { :login => "bob.jones", 
                      :password => "secret", 
                      :password_confirmation => "secret"
                    },
         :return_to => root_path

    assert_response :success
    assert assigns(:person).errors[:email].present?, "Should have error on :email"
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end
  
  def test_create_login_bad_email
    ActionMailer::Base.deliveries.clear
    
    Person.create! :license => "111"
    
    use_ssl
    post :create_login, 
         :person => { 
           :login => "racer@example.com", 
           :email => "http://example.com/", 
           :password => "secret", 
           :password_confirmation => "secret", 
           :license => "111" 
          },
         :return_to => root_path
    assert_response :success
    
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end
  
  def test_new_login
    use_ssl
    get :new_login
    assert_response :success
    assert assigns(:person).new_record?, "@person should be a new record"
  end
  
  def test_new_login_with_token
    person = FactoryGirl.create(:person_with_login)
    person.reset_perishable_token!
    use_ssl
    get :new_login, :id => person.perishable_token
    assert_response :success
    assert !assigns(:person).new_record?, "@person should not be a new record"
  end
  
  def test_new_login_with_token_logged_in
    person = FactoryGirl.create(:person)
    person.reset_perishable_token!
    login_as person
    use_ssl
    get :new_login, :id => person.perishable_token
    assert_response :success
    assert !assigns(:person).new_record?, "@person should not be a new record"
  end
  
  def test_new_login_http
    get :new_login
    if RacingAssociation.current.ssl?
      assert_redirected_to people_new_login_url(secure_redirect_options)
    else
      assert_response :success
    end
  end
  
  def test_create_login_all_blank
    ActionMailer::Base.deliveries.clear
    
    Person.create! :license => "111"
    
    use_ssl
    post :create_login, 
         :person => { 
           :login => "", 
           :email => "racer@example.com", 
           :password => "secret", 
           :password_confirmation => "secret", 
           :license => "",
           :name => ""
          },
         :return_to => root_path
    assert_response :success
    assert assigns(:person).errors[:login].present?, "Should have error on :email"
    assert assigns(:person).new_record?, "Should be a new_record?"
    
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  def test_create_login_login_blank_name_blank
    ActionMailer::Base.deliveries.clear
    
    Person.create! :license => "111"
    
    use_ssl
    post :create_login, 
         :person => { 
           :login => "", 
           :email => "racer@example.com", 
           :password => "secret", 
           :password_confirmation => "secret"
          },
         :return_to => root_path
    assert_response :success
    assert assigns(:person).errors[:login].present?, "Should have error on :email"
    assert assigns(:person).new_record?, "Should be a new_record?"
    
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  def test_create_login_login_blank_license_blank
    ActionMailer::Base.deliveries.clear
    
    Person.create! :license => "111", :name => "Speed Racer"
    
    use_ssl
    post :create_login, 
         :person => { 
           :login => "", 
           :email => "racer@example.com", 
           :password => "secret", 
           :password_confirmation => "secret", 
           :license => "",
           :name => ""
          },
         :return_to => root_path
    assert_response :success
    assert assigns(:person).errors[:login].present?, "Should have error on :email"
    assert assigns(:person).new_record?, "Should be a new_record?"
    
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  def test_create_login_name_blank_license_blank
    ActionMailer::Base.deliveries.clear
    
    Person.create! :license => "111", :name => "Speed Racer", :email => "racer@example.com"
    person_count = Person.count
    
    use_ssl
    post :create_login, 
         :person => { 
           :login => "racer@example.com", 
           :email => "racer@example.com", 
           :password => "secret", 
           :password_confirmation => "secret", 
           :license => "",
           :name => ""
          },
         :return_to => root_path
    assert_redirected_to root_path
    
    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
    assert_equal person_count + 1, Person.count, "Person.count"
  end

  def test_create_login_invalid_login
    ActionMailer::Base.deliveries.clear
    existing_person = Person.create!(:license => "123", :name => "Speed Racer")
    
    use_ssl
    post :create_login, 
         :person => { :login => "!@#$&*()_+?><", 
                      :password => "secret", 
                      :password_confirmation => "secret", 
                      :email => "racer@example.com", 
                      :license => "123",
                      :name => "Speed Racer"
                    },
         :return_to => root_path

   assert_response :success
   assert assigns(:person).errors[:login].present?, "Should have error on :email"
   assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  def test_create_login_unmatched_license
    ActionMailer::Base.deliveries.clear
    existing_person = Person.create!(:license => "123", :name => "Speed Racer")
    people_count = Person.count
    
    use_ssl
    post :create_login, 
         :person => { :login => "speed_racer", 
                      :password => "secret", 
                      :password_confirmation => "secret", 
                      :email => "racer@example.com", 
                      :license => "1727",
                      :name => "Speed Racer"
                    },
         :return_to => root_path

   assert assigns(:person).errors.any?, "Should errors"
   assert_equal 1, assigns(:person).errors.size, "errors"
   assert_response :success
   assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
   assert_equal people_count, Person.count, "People count"
  end

  def test_create_login_unmatched_name
    ActionMailer::Base.deliveries.clear
    existing_person = Person.create!(:license => "123", :name => "Speed Racer")
    people_count = Person.count
    
    use_ssl
    post :create_login, 
         :person => { :login => "speed_racer", 
                      :password => "secret", 
                      :password_confirmation => "secret", 
                      :email => "racer@example.com", 
                      :license => "123",
                      :name => "Vitesse"
                    },
         :return_to => root_path

    assert assigns(:person).errors.any?, "Should errors"
    assert_equal 1, assigns(:person).errors.size, "errors"
    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
    assert_equal people_count, Person.count, "People count"
  end

  def test_create_login_with_current_race_number_and_name
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline)
    
    ActionMailer::Base.deliveries.clear
    existing_person = Person.create!(:license => "123", :name => "Speed Racer", :road_number => "9871")
    
    use_ssl
    post :create_login, 
         :person => { :login => "racer@example.com", 
                      :password => "secret", 
                      :password_confirmation => "secret", 
                      :email => "racer@example.com", 
                      :license => "9871",
                      :name => "Speed Racer"
                    },
         :return_to => root_path
 
    assert assigns(:person).errors.empty?, "Should not have errors, but had: #{assigns(:person).errors.full_messages}"
    assert_redirected_to root_path
    
    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
    assert_equal existing_person, assigns(:person), "Should match existing Person"
  end

  def test_create_login_with_return_to_with_params
    use_ssl
    post :create_login, 
        :person => { 
          :login => "racer@example.com", 
          :password => "secret", 
          :password_confirmation => "secret", 
          :email => "racer@example.com"
         },
         :return_to => "/line_items/create?type=membership"
 
    assert assigns(:person).errors.empty?, "Should not have errors, but had: #{assigns(:person).errors.full_messages}"
    assert_redirected_to "/line_items/create?type=membership"
  end
end
