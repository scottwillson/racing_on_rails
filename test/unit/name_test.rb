require "test_helper"

class NameTest < ActiveSupport::TestCase
 def test_create
   Name.create!(:team_id => teams(:vanilla).id, :name => "Sacha's Team", :year => 2001)
 end
 
 def test_no_duplicates
   Name.create!(:team_id => teams(:vanilla).id, :name => "Sacha's Team", :year => 2001)
   name = Name.create(:team_id => teams(:vanilla).id, :name => "White Express", :year => 2001)
   assert(!name.valid?, "No duplications")
 end
end