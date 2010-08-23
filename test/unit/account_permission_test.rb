require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class AccountPermissionTest < ActiveSupport::TestCase
  def test_editors
    person = people(:member)
    assert person.editors.empty?, "editors should be empty"
    assert person.editable_people.empty?, "editable_people should be empty"
    
    another_person = Person.create!
    person.editors << another_person
    assert_equal [ another_person ], person.editors, "editors"
    assert another_person.editors.empty?, "editors should be empty"
    assert person.editable_people.empty?, "editable_people should be empty"
    assert_equal [ person ], another_person.editable_people, "editable_people"
    
    another_person.editors << person
    assert_equal [ another_person ], person.editors, "editors"
    assert_equal [ person ], another_person.editors, "editors"
    assert_equal [ another_person ], person.editable_people(true), "editable_people"
    assert_equal [ person ], another_person.editable_people, "editable_people"

    assert_raise(ActiveRecord::ActiveRecordError, "should not allow duplicates") { person.editors << another_person }
    assert_raise(ActiveRecord::ActiveRecordError, "should not allow duplicates") { another_person.editors << person }
    
    person.editors.delete another_person
    assert person.editors.empty?, "editors should be empty"
    
    another_person.editors.delete person
    assert another_person.editors.empty?, "editors should be empty"
  end

  def test_account_permissions
    person = Person.create!(:name => "Person")
    assert_equal [], person.account_permissions, "account_permissions for new Person"

    another_person = Person.create!(:name => "Another")
    person.editors << another_person
    assert_equal 1, person.account_permissions.size, "account_permissions size"
    account_permission = person.account_permissions.first
    assert_equal another_person, account_permission.person, "person"
    assert_equal false, account_permission.can_edit_person?, "can_edit_person?"
    assert_equal true, account_permission.person_can_edit?, "person_can_edit?"

    assert_equal 1, another_person.account_permissions.size, "account_permissions size"
    account_permission = another_person.account_permissions.first
    assert_equal person, account_permission.person, "person"
    assert_equal true, account_permission.can_edit_person?, "can_edit_person?"
    assert_equal false, account_permission.person_can_edit?, "person_can_edit?"

    another_person.editors << person
    person.editable_people(true)
    assert_equal 1, person.account_permissions.size, "account_permissions size"
    account_permission_editable_person = person.account_permissions.detect { |ap| ap.person == another_person }
    assert_not_nil account_permission_editable_person, "Should find editable Person"
    assert_equal true, account_permission_editable_person.can_edit_person?, "can_edit_person?"
    assert_equal true, account_permission_editable_person.person_can_edit?, "person_can_edit?"
  end
end
