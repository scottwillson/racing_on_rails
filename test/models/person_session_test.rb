require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class PersonSessionTest < ActiveSupport::TestCase
  test "login should be case insensitive" do
    FactoryGirl.create(:person_with_login, login: "my.name@example.com")
    session = PersonSession.new(login: "My.name@example.com", password: "secret")
    assert session.save, "Should create session"
  end
end
