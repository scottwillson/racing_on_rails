require File.dirname(__FILE__) + '/../test_helper'

class HistoricalNameTest < ActiveSupport::TestCase
 def test_create
   HistoricalName.create!(:team_id => teams(:vanilla).id, :name => "Sacha's Team", :year => 2001)
 end
 
 def test_no_duplicates
   HistoricalName.create!(:team_id => teams(:vanilla).id, :name => "Sacha's Team", :year => 2001)
   historical_name = HistoricalName.create(:team_id => teams(:vanilla).id, :name => "White Express", :year => 2001)
   assert(!historical_name.valid?, "No duplications")
 end
end