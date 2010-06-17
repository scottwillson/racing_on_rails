require "test_helper"

class NameTest < ActiveSupport::TestCase
  def test_create
    teams(:vanilla).names.create!(:name => "Sacha's Team", :year => 2001)
  end

  def test_no_duplicates
    teams(:vanilla).names.create!(:name => "Sacha's Team", :year => 2001)
    name = teams(:vanilla).names.create(:name => "White Express", :year => 2001)
    assert(!name.valid?, "No duplications")
  end
end
