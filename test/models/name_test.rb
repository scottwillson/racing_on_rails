require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class NameTest < ActiveSupport::TestCase
  def test_no_duplicates
    team = FactoryGirl.create(:team)
    team.names.create!(name: "Sacha's Team", year: 2001)
    name = team.names.build(name: "White Express", year: 2001)
    assert(!name.valid?, "No duplications")
  end
end
