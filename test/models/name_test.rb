# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

# :stopdoc:
class NameTest < ActiveSupport::TestCase
  test "no duplicates" do
    team = FactoryBot.create(:team)
    team.names.create!(name: "Sacha's Team", year: 2001)
    name = team.names.build(name: "White Express", year: 2001)
    assert_not(name.valid?, "No duplications")
  end
end
