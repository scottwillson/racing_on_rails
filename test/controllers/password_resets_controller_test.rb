require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PasswordResetsControllerTest < ActionController::TestCase
  def setup
    super
    use_ssl
  end

  test "forgot password" do
    ActionMailer::Base.deliveries.clear
    FactoryGirl.create(:administrator)
    post :create, email: "admin@example.com"
    assert_response :redirect
    assert_redirected_to new_password_reset_url(secure_redirect_options)
    assert_equal 1, ActionMailer::Base.deliveries.count, "Should send one email"
  end

  test "forgot password error" do
    ActionMailer::Base.deliveries.clear
    post :create, email: "noperson@example.com"
    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.count, "Should send one email"
  end

  test "forgot password invalid email" do
    ActionMailer::Base.deliveries.clear
    post :create, email: "bob.jones"
    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.count, "Should send one email"
  end

  test "forgot password blank email" do
    ActionMailer::Base.deliveries.clear
    Person.create! email: ""
    post :create, email: ""
    assert_response :success
    assert_equal 0, ActionMailer::Base.deliveries.count, "Should send one email"
  end

  test "edit" do
    member = FactoryGirl.create(:person_with_login)
    get :edit, id: member.perishable_token
    assert_response :success
    assert_equal(member, assigns["person"], "@person")
  end

  test "update admin" do
    administrator = FactoryGirl.create(:administrator)
    password = administrator.crypted_password
    post :update, id: administrator.perishable_token, person: { password: "my new password", password_confirmation: "my new password" }
    assert_not_nil(assigns["person"], "@person")
    assert_not_nil(assigns["person_session"], "@person_session")
    updated_person = Person.find(administrator.id)
    assert(password != updated_person.crypted_password, "Password should change")
    assert_equal "admin@example.com", updated_person.login, "login"
    assert_redirected_to admin_home_path
  end

  test "update member" do
    person = FactoryGirl.create(:person_with_login, login: "bob.jones")
    password = person.crypted_password
    post :update, id: person.perishable_token, person: { password: "my new password", password_confirmation: "my new password" }
    assert_not_nil(assigns["person"], "@person")
    assert_not_nil(assigns["person_session"], "@person_session")
    assert assigns["person"].errors.empty?, assigns["person"].errors.full_messages.join
    updated_person = Person.find(person.id)
    assert(password != updated_person.crypted_password, "Password should change")
    assert_equal "bob.jones", updated_person.login, "login"
    assert(password != Person.find(updated_person.id).crypted_password, "Password should change")
    assert flash[:notice].present?, "Shoudl set flash :notice"
    assert_redirected_to "/account"
  end

  test "invalid update" do
    member = FactoryGirl.create(:person_with_login, login: "bob.jones")
    password = member.crypted_password
    post :update, id: member.perishable_token, person: { password: "my new password", password_confirmation: "another password that doesn't match" }
    assert_nil(assigns["person_session"], "@person_session")
    assert_not_nil(assigns["person"], "@person")
    assert_not_nil(assigns("person").errors[:password], "Should have error on password")
    updated_person = Person.find(member.id)
    assert(password == Person.find(updated_person.id).crypted_password, "Password should not change")
    assert_equal "bob.jones", updated_person.login, "login"
    assert_response :success
  end

  test "blank update" do
    member = FactoryGirl.create(:person_with_login)
    password = member.crypted_password
    post :update, id: member.perishable_token, person: { password: "", password_confirmation: "" }
    assert_nil(assigns["person_session"], "@person_session")
    assert_not_nil(assigns["person"], "@person")
    assert_not_nil(assigns("person").errors[:password], "Should have error on password")
    assert(password == Person.find(member.id).crypted_password, "Password should not change")
    assert_response :success
  end
end
