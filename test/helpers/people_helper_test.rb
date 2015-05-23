require_relative "../test_helper"

# :stopdoc:
# Helper tests need explicit mobile param
class PeopleHelperTest < ActionView::TestCase
  test "person editing own account" do
    person = FactoryGirl.create(:person)
    current_person = person
    assert_equal(
      edit_person_path(person, mobile: nil),
      account_permission_return_to(person, current_person))
  end

  test "edit different person" do
    person = FactoryGirl.create(:person)
    current_person = FactoryGirl.create(:person)
    assert_equal(
      edit_person_path(person, mobile: nil),
      account_permission_return_to(person, current_person))
  end

  test "administrator editing other's account" do
    person = FactoryGirl.create(:person)
    current_person = FactoryGirl.create(:administrator)
    assert_equal(
      edit_admin_person_path(person, mobile: nil),
      account_permission_return_to(person, current_person))
  end

  test "administrator editing own account" do
    person = FactoryGirl.create(:administrator)
    current_person = person
    assert_equal(
      edit_admin_person_path(person, mobile: nil),
      account_permission_return_to(person, current_person))
  end

  test "new person" do
    person = Person.new
    current_person = FactoryGirl.create(:person)
    assert_equal(nil, account_permission_return_to(person, current_person))
  end
end
