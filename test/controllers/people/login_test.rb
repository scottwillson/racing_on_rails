# coding: utf-8

require File.expand_path("../../../test_helper", __FILE__)

# :stopdoc:
class LoginTest < ActionController::TestCase
  tests PeopleController

  test "create login" do
    ActionMailer::Base.deliveries.clear

    use_ssl
    post :create_login,
         person: {
           login: "racer@example.com",
           password: "secret",
           password_confirmation: "secret",
           email: "racer@example.com",
           license: ""
          },
         return_to: root_path
    assert_redirected_to root_path

    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
    person = Person.last
    assert_equal 1, person.versions(true).size
    assert_equal person, person.created_by, "created_by not set for #{person.versions.first.inspect}"
  end

  test "create login with token" do
    ActionMailer::Base.deliveries.clear

    person = FactoryGirl.create(:person)
    person.reset_perishable_token!
    use_ssl
    post :create_login,
         person: {
           login: "racer@example.com",
           password: "secret",
           password_confirmation: "secret",
           email: "racer@example.com"
          },
         id: person.perishable_token
    assert_redirected_to edit_person_path(person)

    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
  end

  test "create login with name" do
    ActionMailer::Base.deliveries.clear

    use_ssl
    post :create_login,
         person: {
           login: "racer@example.com",
           name: "Bike Racer",
           password: "secret",
           password_confirmation: "secret",
           email: "racer@example.com",
           license: ""
          },
         return_to: root_path
    assert_redirected_to root_path

    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
  end

  test "create login with license and name" do
    ActionMailer::Base.deliveries.clear
    existing_person = Person.create!(license: "123", name: "Speed Racer")

    use_ssl
    post :create_login,
         person: { login: "racer@example.com",
                      password: "secret",
                      password_confirmation: "secret",
                      email: "racer@example.com",
                      license: "123   ",
                      name: "    Speed Racer"
                    },
         return_to: root_path

    assert assigns(:person).errors.empty?, "Should not have errors, but had: #{assigns(:person).errors.full_messages}"
    assert_redirected_to root_path

    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
    assert_equal existing_person, assigns(:person), "Should match existing Person"
  end

  test "create login with license in name field" do
    ActionMailer::Base.deliveries.clear
    Person.create!(license: "123", name: "Speed Racer")

    use_ssl
    post :create_login,
         person: { login: "racer@example.com",
                      password: "secret",
                      password_confirmation: "secret",
                      email: "racer@example.com",
                      license: "Speed Racer",
                      name: ""
                    },
         return_to: root_path

    assert_response :success
    assert assigns(:person).errors[:name].present?, "Should have error on :name"
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  test "create login with reversed fields" do
    ActionMailer::Base.deliveries.clear
    Person.create!(license: "123", name: "Speed Racer")

    use_ssl
    post :create_login,
         person: { login: "racer@example.com",
                      password: "secret",
                      password_confirmation: "secret",
                      email: "racer@example.com",
                      license: "Speed Racer",
                      name: "123"
                    },
         return_to: root_path

    assert_response :success
    assert assigns(:person).errors.any?, "Should have errors"
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  test "create login blank license" do
    ActionMailer::Base.deliveries.clear
    people_count = Person.count

    use_ssl
    post :create_login,
         person: { login: "racer@example.com", email: "racer@example.com", password: "secret",
                      password_confirmation: "secret", license: "" },
         return_to: root_path
    assert_redirected_to root_path

    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
    assert_equal people_count + 1, Person.count, "People count. Should add one."
  end

  test "create login no email" do
    ActionMailer::Base.deliveries.clear

    Person.create! license: "111", email: "racer@example.com"

    use_ssl
    post :create_login,
         person: { login: "racer@example.com",
                      password: "secret",
                      password_confirmation: "secret",
                      email: ""
                    },
         return_to: root_path

    assert_response :success
    assert assigns(:person).errors[:email].present?, "Should have error on :email"
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  test "create dupe login no email" do
    ActionMailer::Base.deliveries.clear

    use_ssl
    post :create_login,
         person: { login: "bob.jones",
                      password: "secret",
                      password_confirmation: "secret"
                    },
         return_to: root_path

    assert_response :success
    assert assigns(:person).errors[:email].present?, "Should have error on :email"
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  test "create login bad email" do
    ActionMailer::Base.deliveries.clear

    Person.create! license: "111"

    use_ssl
    post :create_login,
         person: {
           login: "racer@example.com",
           email: "http://example.com/",
           password: "secret",
           password_confirmation: "secret",
           license: "111"
          },
         return_to: root_path
    assert_response :success

    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  test "new login" do
    use_ssl
    get :new_login
    assert_response :success
    assert assigns(:person).new_record?, "@person should be a new record"
  end

  test "new login with token" do
    person = FactoryGirl.create(:person_with_login)
    person.reset_perishable_token!
    use_ssl
    get :new_login, id: person.perishable_token
    assert_response :success
    assert !assigns(:person).new_record?, "@person should not be a new record"
  end

  test "new login with token logged in" do
    person = FactoryGirl.create(:person)
    person.reset_perishable_token!
    login_as person
    use_ssl
    get :new_login, id: person.perishable_token
    assert_response :success
    assert !assigns(:person).new_record?, "@person should not be a new record"
  end

  test "new login http" do
    get :new_login
    if RacingAssociation.current.ssl?
      assert_redirected_to people_new_login_url(secure_redirect_options)
    else
      assert_response :success
    end
  end

  test "create login all blank" do
    ActionMailer::Base.deliveries.clear

    Person.create! license: "111"

    use_ssl
    post :create_login,
         person: {
           login: "",
           email: "racer@example.com",
           password: "secret",
           password_confirmation: "secret",
           license: "",
           name: ""
          },
         return_to: root_path
    assert_response :success
    assert assigns(:person).errors[:login].present?, "Should have error on :email"
    assert assigns(:person).new_record?, "Should be a new_record?"

    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  test "create login login blank name blank" do
    ActionMailer::Base.deliveries.clear

    Person.create! license: "111"

    use_ssl
    post :create_login,
         person: {
           login: "",
           email: "racer@example.com",
           password: "secret",
           password_confirmation: "secret"
          },
         return_to: root_path
    assert_response :success
    assert assigns(:person).errors[:login].present?, "Should have error on :email"
    assert assigns(:person).new_record?, "Should be a new_record?"

    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  test "create login login blank license blank" do
    ActionMailer::Base.deliveries.clear

    Person.create! license: "111", name: "Speed Racer"

    use_ssl
    post :create_login,
         person: {
           login: "",
           email: "racer@example.com",
           password: "secret",
           password_confirmation: "secret",
           license: "",
           name: ""
          },
         return_to: root_path
    assert_response :success
    assert assigns(:person).errors[:login].present?, "Should have error on :email"
    assert assigns(:person).new_record?, "Should be a new_record?"

    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  test "create login name blank license blank" do
    ActionMailer::Base.deliveries.clear

    Person.create! license: "111", name: "Speed Racer", email: "racer@example.com"
    person_count = Person.count

    use_ssl
    post :create_login,
         person: {
           login: "racer@example.com",
           email: "racer@example.com",
           password: "secret",
           password_confirmation: "secret",
           license: "",
           name: ""
          },
         return_to: root_path
    assert_redirected_to root_path

    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
    assert_equal person_count + 1, Person.count, "Person.count"
  end

  test "create login invalid login" do
    ActionMailer::Base.deliveries.clear
    Person.create!(license: "123", name: "Speed Racer")

    use_ssl
    post :create_login,
         person: { login: "!@#$&*()_+?><",
                      password: "secret",
                      password_confirmation: "secret",
                      email: "racer@example.com",
                      license: "123",
                      name: "Speed Racer"
                    },
         return_to: root_path

   assert_response :success
   assert assigns(:person).errors[:login].present?, "Should have error on :email"
   assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
  end

  test "create login unmatched license" do
    ActionMailer::Base.deliveries.clear
    Person.create!(license: "123", name: "Speed Racer")
    people_count = Person.count

    use_ssl
    post :create_login,
         person: { login: "speed_racer",
                      password: "secret",
                      password_confirmation: "secret",
                      email: "racer@example.com",
                      license: "1727",
                      name: "Speed Racer"
                    },
         return_to: root_path

   assert assigns(:person).errors.any?, "Should errors"
   assert_equal 1, assigns(:person).errors.size, "errors"
   assert_response :success
   assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
   assert_equal people_count, Person.count, "People count"
  end

  test "create login unmatched name" do
    ActionMailer::Base.deliveries.clear
    Person.create!(license: "123", name: "Speed Racer")
    people_count = Person.count

    use_ssl
    post :create_login,
         person: { login: "speed_racer",
                      password: "secret",
                      password_confirmation: "secret",
                      email: "racer@example.com",
                      license: "123",
                      name: "Vitesse"
                    },
         return_to: root_path

    assert assigns(:person).errors.any?, "Should errors"
    assert_equal 1, assigns(:person).errors.size, "errors"
    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.size, "Should not deliver confirmation email"
    assert_equal people_count, Person.count, "People count"
  end

  test "create login with current race number and name" do
    FactoryGirl.create(:number_issuer)
    FactoryGirl.create(:discipline)

    ActionMailer::Base.deliveries.clear
    existing_person = Person.create!(license: "123", name: "Speed Racer", road_number: "9871")

    use_ssl
    post :create_login,
         person: { login: "racer@example.com",
                      password: "secret",
                      password_confirmation: "secret",
                      email: "racer@example.com",
                      license: "9871",
                      name: "Speed Racer"
                    },
         return_to: root_path

    assert assigns(:person).errors.empty?, "Should not have errors, but had: #{assigns(:person).errors.full_messages}"
    assert_redirected_to root_path

    assert_equal 1, ActionMailer::Base.deliveries.size, "Should deliver confirmation email"
    assert_equal existing_person, assigns(:person), "Should match existing Person"
  end

  test "create login with return to with params" do
    use_ssl
    post :create_login,
        person: {
          login: "racer@example.com",
          password: "secret",
          password_confirmation: "secret",
          email: "racer@example.com"
         },
         return_to: "/line_items/create?type=membership"

    assert assigns(:person).errors.empty?, "Should not have errors, but had: #{assigns(:person).errors.full_messages}"
    assert_redirected_to "/line_items/create?type=membership"
  end
end
