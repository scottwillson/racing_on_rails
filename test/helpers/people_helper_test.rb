# frozen_string_literal: true

require_relative "../test_helper"

# :stopdoc:
class PeopleHelperTest < ActionView::TestCase
  test "person editing own account" do
    person = FactoryBot.create(:person)
    current_person = person
    assert_equal(
      edit_person_path(person),
      account_permission_return_to(person, current_person)
    )
  end

  test "edit different person" do
    person = FactoryBot.create(:person)
    current_person = FactoryBot.create(:person)
    assert_equal(
      edit_person_path(person),
      account_permission_return_to(person, current_person)
    )
  end

  test "administrator editing other's account" do
    person = FactoryBot.create(:person)
    current_person = FactoryBot.create(:administrator)
    assert_equal(
      edit_admin_person_path(person),
      account_permission_return_to(person, current_person)
    )
  end

  test "administrator editing own account" do
    person = FactoryBot.create(:administrator)
    current_person = person
    assert_equal(
      edit_admin_person_path(person),
      account_permission_return_to(person, current_person)
    )
  end

  test "new person" do
    person = Person.new
    current_person = FactoryBot.create(:person)
    assert_nil(account_permission_return_to(person, current_person))
  end
end
