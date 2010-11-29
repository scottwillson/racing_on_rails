# coding: utf-8

require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PeopleControllerTest < ActionController::TestCase
  def test_index
    get(:index)
    assert_response(:success)
    assert_template("people/index")
    assert_layout("application")
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should find no one")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_select ".tabs", :count => 0
    assert_select "a#export_link", :count => 0
  end

  def test_list
    get(:list, :q => 'jone')
    assert_response(:success)
    assert_not_nil(@response.body.index("Jones"), 'Search for jone should find Jones #{@response.to_s}')
    assert_not_nil(@response.body.index("2"), 'Search for jone should return ID of 2')
  end

  def test_index_as_promoter
    PersonSession.create(people(:promoter))
    get(:index)
    assert_response(:success)
    assert_template("people/index")
    assert_layout("application")
    assert_not_nil(assigns["people"], "Should assign people")
    assert(assigns["people"].empty?, "Should find no one")
    assert_not_nil(assigns["name"], "Should assign name")
    assert_select ".tabs", :count => 1
    assert_select "a#export_link", :count => 1
  end

  def test_find
    get(:index, :name => "weav")
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal([people(:weaver)], assigns['people'], 'Search for weav should find Weaver')
    assert_not_nil(assigns["name"], "Should assign name")
    assert_equal('weav', assigns['name'], "'name' assigns")
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
    for i in 0..RacingAssociation.current.search_results_limit
      Person.create(:name => "Test Person #{i}")
    end
    get(:index, :name => 'Test')
    assert_response(:success)
    assert_not_nil(assigns["people"], "Should assign people")
    assert_equal(30, assigns['people'].size, "Search for '' should find all people and paginate")
    assert_not_nil(assigns["name"], "Should assign name")
    assert(flash.empty?, 'flash not empty?')
    assert_equal('Test', assigns['name'], "'name' assigns")
  end

  def test_ajax_ssl_find
    use_ssl
    xhr :get, :index, :name => "weav"
    assert_response :success
    assert_not_nil assigns["people"], "Should assign people"
    assert_equal [ people(:weaver) ], assigns['people'], "Search for weav should find Weaver"
    assert_template "people/index"
    assert_layout nil
  end
  
  def test_edit
    use_ssl
    login_as :member
    get :edit, :id => people(:member).to_param
    assert_response :success
    assert_equal people(:member), assigns(:person), "@person"
    assert_select ".tabs", :count => 0
  end

  def test_edit_promoter
    use_ssl
    login_as :promoter
    get :edit, :id => people(:promoter).to_param
    assert_response :success
    assert_equal people(:promoter), assigns(:person), "@person"
    assert_select ".tabs", :count => 1
  end

  def test_edit_as_editor
    people(:molly).editors << people(:member)
    use_ssl
    login_as :member
    get :edit, :id => people(:molly).to_param
    assert_response :success
    assert_equal people(:molly), assigns(:person), "@person"
    assert_select ".tabs", :count => 0
  end

  def test_must_be_logged_in
    use_ssl
    get :edit, :id => people(:member).to_param
    assert_redirected_to(new_person_session_url(secure_redirect_options))
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
    person = Person.find(person.id)
    assert_equal teams(:gentle_lovers), person.reload.team, "Team should be updated"
    assert_equal 1, person.versions.size, "versions"
    version = person.versions.last
    assert_equal person, version.user, "version user"
    changes = version.changes
    assert_equal 1, changes.size, "changes"
    change = changes["team_id"]
    assert_not_nil change, "Should have change for team ID"
    assert_equal nil, change.first, "Team ID before"
    assert_equal Team.find_by_name("Gentle Lovers").id, change.last, "Team ID after"
    assert_equal "Bob Jones", person.last_updated_by, "last_updated_by"
    # VestalVersions convention
    assert_nil person.updated_by, "updated_by"
  end
  
  def test_update_no_name
    use_ssl
    editor = Person.create!(:login => "my_login")
    editor.roles << roles(:administrator)
    editor.save!
    
    login_as editor
    
    person = people(:member)
    put :update, :id => person.to_param, :person => { :team_name => "Gentle Lovers" }
    assert_redirected_to edit_person_path(person)
    person = Person.find(person.id)
    assert_equal teams(:gentle_lovers), person.reload.team, "Team should be updated"
    assert_equal 1, person.versions.size, "versions"
    version = person.versions.last
    assert_equal editor, version.user, "version user"
    changes = version.changes
    assert_equal 1, changes.size, "changes"
    change = changes["team_id"]
    assert_not_nil change, "Should have change for team ID"
    assert_equal nil, change.first, "Team ID before"
    assert_equal Team.find_by_name("Gentle Lovers").id, change.last, "Team ID after"
    assert_equal "my_login", person.last_updated_by, "last_updated_by"
    # VestalVersions convention
    assert_nil person.updated_by, "updated_by"
  end
  
  def test_update_by_editor
    people(:member).editors << people(:molly)

    use_ssl
    person = people(:member)
    login_as :molly
    put :update, :id => person.to_param, :person => { :team_name => "Gentle Lovers" }
    assert_redirected_to edit_person_path(person)
    assert_equal teams(:gentle_lovers), person.reload.team(true), "Team should be updated"
  end
  
  def test_account
    use_ssl
    login_as :member
    get :account
    assert_redirected_to edit_person_path(people(:member))
  end
  
  def test_account_with_person
    use_ssl
    login_as :member
    get :account, :id => people(:member).to_param
    assert_redirected_to edit_person_path(people(:member))
  end
  
  def test_account_with_another_person
    use_ssl
    login_as :member
    another_person = Person.create!
    get :account, :id => another_person.to_param
    assert_redirected_to edit_person_path(another_person)
  end
  
  def test_account_not_logged_in
    use_ssl
    get :account
    assert_redirected_to(new_person_session_url(secure_redirect_options))
  end
  
  def test_account_with_person_not_logged_in
    use_ssl
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
    assert assigns(:person).errors.on(:name), "Should have error on :name"
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
    assert assigns(:person).errors.on(:email), "Should have error on :email"
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
    assert assigns(:person).errors.on(:email), "Should have error on :login"
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
  end
  
  def test_new_login_http
    get :new_login
    if RacingAssociation.current.ssl?
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
    assert assigns(:person).errors.on(:login), "Should have error on :login"
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
    assert assigns(:person).errors.on(:login), "Should have error on :login"
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
   assert assigns(:person).errors.on(:login), "Should have error on :login"
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

  def test_new_when_logged_in
    login_as :member
    use_ssl
    get :new_login
    assert_redirected_to edit_person_path(people(:member))
    assert_not_nil flash[:notice], "flash[:notice]"
  end

  def test_index_as_xml
    get :index, :license => 7123811, :format => "xml"
    assert_response :success
    assert_equal "application/xml", @response.content_type
    [
      "person > first-name",
      "person > last-name",
      "person > date-of-birth",
      "person > license",
      "person > gender",
      "person > team",
      "person > race-numbers",
      "person > aliases",
      "team > city",
      "team > state",
      "team > website",
      "race-numbers > race-number",
      "race-number > value",
      "race-number > year",
      "race-number > discipline",
      "discipline > name",
      "aliases > alias",
      "alias > name",
      "alias > alias"
    ].each do |key|
      assert_select key
    end
  end

  def test_index_as_json
    get :index, :format => "json", :name => "ron"
    assert_response :success
    assert_equal "application/json", @response.content_type
  end
  
  def test_find_by_name_as_xml
    get :index, :name => "ron", :format => "xml"
    assert_response :success
    assert_select "first-name", "Molly"
    assert_select "first-name", "Kevin"
  end
  
  def test_find_by_license_as_xml
    get :index, :name => "m", :license => 576, :format => "xml"
    assert_response :success
    assert_select "first-name", "Mark"
  end

  def test_show_as_xml
    get :show, :id => people(:molly).id, :format => "xml"
    assert_response :success
    assert_select "first-name", "Molly"
    assert_select "last-name", "Cameron"
  end

  def test_show_as_json
    get :show, :id => people(:molly).id, :format => "json"
    assert_response :success
  end
end
