require "test_helper"

module RacingOnRails
  module VestalVersions
    # :stopdoc:
    class VersionedTest < ActiveSupport::TestCase
      test "updated by person name" do
        person = Person.create!(updated_by: "Bike race")
        assert_equal "Bike race", person.updated_by_person_name, "updated_by_person_name"
      end
    end
  end
end
