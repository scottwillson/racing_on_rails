require File.dirname(__FILE__) + '/../test_helper'
require 'schedule_controller'

# Re-raise errors caught by the controller.
class ScheduleController; def rescue_action(e) raise e end; end

class ScheduleControllerTest < Test::Unit::TestCase

  fixtures :promoters, :events, :aliases_disciplines, :disciplines, :users

  def setup
    @controller = ScheduleController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    events = []
    year = 2006
    
    banana_belt = SingleDayEvent.new(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://www.obra.org/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    events << banana_belt
    banana_belt.save!
    
    mud_slinger = SingleDayEvent.new(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://www.obra.org/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => {:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :phone => "203-259-8577"}
    )
    events << mud_slinger
    mud_slinger.save!

    opts = {:controller => "schedule", :action => "index", :year => year.to_s}
    assert_routing("schedule/#{year}", opts)
    get(:index, {:year => year})

    html = @response.body
    assert(html =~ /Mudslinger\s*MTB/, "Mountain Bike events should include MTB")
    for event in events
      assert(html[event.name], "'#{event.name}' should be in HTML")
    end
    assert(html["banana_belt.html"], "Schedule should include Banana Belt flyer URL")
    assert(!html["mud_slinger.html"], "Schedule should not include Mudslinger flyer URL")
    
  end
end
