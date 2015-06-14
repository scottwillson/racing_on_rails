require_relative "../test_helper"

# :stopdoc:
class SimilarPersonTest < ActiveSupport::TestCase
  test "none" do
    assert SimilarPerson.all.empty?
  end

  test "all" do
    sam_1 = Person.create!(name: "Sam Willson")
            Person.create!(name: "John Hunt")
    sam_2 = Person.create!(name: "Sam Willson")

    similar_people = SimilarPerson.all
    assert_same_elements [ sam_1, sam_2 ], similar_people, "similar people"
  end
end
