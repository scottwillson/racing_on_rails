require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class VersionedTest < ActiveSupport::TestCase
  test "updated_by_person_name" do
    person = Person.create!(updated_by: "Bike race")
    assert_equal "Bike race", person.updated_by_person_name, "updated_by_person_name"
  end
end
