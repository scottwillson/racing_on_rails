# frozen_string_literal: true

require "test_helper"

module RacingOnRails
  module VestalVersions
    # :stopdoc:
    class VersionedTest < ActiveSupport::TestCase
      test "updated by person name" do
        person = ::Person.create!(updater: ::Event.new(name: "Bike race"))
        assert_equal "Bike race", person.updated_by_paper_trail_name, "updated_by_paper_trail_name"
      end
    end
  end
end
