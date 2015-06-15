require_relative "../test_helper"

# :stopdoc:
class DuplicatePersonTest < ActiveSupport::TestCase
  test "none" do
    assert DuplicatePerson.all.empty?
  end

  test "all" do
    sam_1 = Person.create!(name: "Sam Willson")
            Person.create!(name: "John Hunt")
    sam_2 = Person.create!(name: "Sam Willson")
    Person.create!(name: "Steve Smith", other_people_with_same_name: true)
    Person.create!(name: "Steve Smith", other_people_with_same_name: true)

    duplicate_people = DuplicatePerson.all
    assert_same_elements [ sam_1, sam_2 ], duplicate_people, "similar duplicate_people"
  end
end
