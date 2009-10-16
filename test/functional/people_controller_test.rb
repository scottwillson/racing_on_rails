require "test_helper"

class PeopleControllerTest < ActionController::TestCase
  setup :activate_authlogic

  def test_index
    get(:index)
    assert_response(:success)
    assert_template("people/index")
    assert_layout("application")
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should find no one")
    assert_not_nil(assigns["name"], "Should assign name")
  end

  def test_find
    get(:index, :name => 'weav')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal([people(:weaver)], assigns['people'], 'Search for weav should find Weaver')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  def test_find_nothing
    get(:index, :name => 's7dfnacs89danfx')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(0, assigns['people'].size, "Should find no people")
  end
  
  def test_find_empty_name
    get(:index, :name => '')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should find no one")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('', assigns['name'], "'name' assigns")
  end

  def test_find_limit
    for i in 0..SEARCH_RESULTS_LIMIT
      Person.create(:name => "Test Person #{i}")
    end
    get(:index, :name => 'Test')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(30, assigns['people'].size, "Search for '' should find all people and paginate")
    assert_not_nil(assigns["name"], "Should assign name")
    assert(flash.empty?, 'flash not empty?')
    assert_equal('', assigns['name'], "'name' assigns")
  end
  
  def test_edit
    use_ssl
    login_as :member
    get :edit, :id => people(:member).to_param
    assert_response :success
    assert_equal people(:member), assigns(:person), "@person"
  end

  def test_must_be_logged_in
    use_ssl
    get :edit, :id => people(:member).to_param
    assert_redirected_to new_person_session_path
  end

  def test_cant_see_other_people_info
    use_ssl
    login_as :member
    get :edit, :id => people(:weaver).to_param
    assert_redirected_to unauthorized_path
  end

  def test_admins_can_see_people_info
    use_ssl
    login_as :administrator
    get :edit, :id => people(:member).to_param
    assert_response :success
    assert_equal people(:member), assigns(:person), "@person"
  end
  
  def test_update
    use_ssl
    person = people(:member)
    login_as :member
    put :update, :id => person.to_param, :person => { :team_name => "Gentle Lovers" }
    assert_redirected_to edit_person_path(person)
    assert_equal teams(:gentle_lovers), person.reload.team(true), "Team should be updated"
  end
  
  def test_account
    login_as :member
    get :account
    assert_redirected_to edit_person_path(people(:member))
  end
  
  def test_account_with_person
    login_as :member
    get :account, :id => people(:member).to_param
    assert_redirected_to edit_person_path(people(:member))
  end
  
  def test_account_with_another_person
    login_as :member
    another_person = Person.create!
    get :account, :id => another_person.to_param
    assert_redirected_to edit_person_path(another_person)
  end
  
  def test_account_not_logged_in
    get :account
    assert_redirected_to new_person_session_path
  end
  
  def test_account_with_person_not_logged_in
    get :account, :id => people(:member).to_param
    assert_redirected_to edit_person_path(people(:member))
  end

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
                      :license => "111", 
                      :email => "" 
                    },
         :return_to => root_path

    assert_response :success
    assert assigns(:person).errors.on(:email), "Should have error on :email"
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
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
    
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
  end
  
  def test_new_login
    use_ssl
    get :new_login
    assert_response :success
  end
  
  def test_new_login_http
    get :new_login
    if ASSOCIATION.ssl?
      assert_redirected_to new_login_people_url(:protocol => "https")
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
    assert assigns(:person).errors.on(:login), "Should have error on :login"
    assert assigns(:person).new_record?, "Should be a new_record?"
    
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
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
           :password_confirmation => "secret", 
           :license => "111",
           :name => ""
          },
         :return_to => root_path
    assert_response :success
    assert assigns(:person).errors.on(:login), "Should have error on :login"
    assert assigns(:person).new_record?, "Should be a new_record?"
    
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
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
           :name => "Speed Racer"
          },
         :return_to => root_path
    assert_response :success
    assert assigns(:person).errors.on(:login), "Should have error on :login"
    assert assigns(:person).new_record?, "Should be a new_record?"
    
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
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
   assert assigns(:person).errors.on(:login), "Should have error on :login"
   assert_equal 0, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
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
   assert_equal 0, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
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
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
    assert_equal people_count, Person.count, "People count"
  end

  def test_new_when_logged_in
    login_as :member
    use_ssl
    get :new_login
    assert_redirected_to edit_person_path(people(:member))
    assert_not_nil flash[:notice], "flash[:notice]"
  end
end
