# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class DuplicateTest < ActiveSupport::TestCase
  test "create" do
    tonkin = FactoryBot.create(:person)
    alice = FactoryBot.create(:person)

    new_person = { first_name: "Magnus", last_name: "Tonkin" }
    Duplicate.create!(new_attributes: new_person, people: [tonkin, alice])
    dupes = Duplicate.all
    assert_equal(1, dupes.size, "Dupes")
    dupe = dupes.first
    assert_not_nil(dupe.new_attributes, "dupe.new_person")
    assert_not_nil(dupe.new_attributes, "dupe.new_attributes")
    assert_equal(new_person, dupe.new_attributes)
    assert_equal([tonkin, alice], dupe.people, "people")
  end
end
