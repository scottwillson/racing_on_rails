require "test_helper"

# :stopdoc:
class ScheduleControllerTest < ActionController::TestCase #:nodoc: all
  def test_index
    events = []
    year = 2006
    
    banana_belt = SingleDayEvent.new(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://#{STATIC_HOST}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    events << banana_belt
    banana_belt.save!
    
    mud_slinger = SingleDayEvent.new(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{STATIC_HOST}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Promoter.new(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :phone => "203-259-8577")
    )
    events << mud_slinger
    mud_slinger.save!

    opts = {:controller => "schedule", :action => "index", :year => year.to_s}
    assert_routing("schedule/#{year}", opts)
    get(:index, {:year => year})

    html = @response.body
    for event in events
      assert(html[event.name], "'#{event.name}' should be in HTML")
    end
    assert(html["banana_belt.html"], "Schedule should include Banana Belt flyer URL")
    assert(!html["mud_slinger.html"], "Schedule should not include Mudslinger flyer URL")
  end
  
  def test_index_only_shows_visible_events
    get :index
    html = @response.body
    
    assert_equal(
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar?,
      !html[events(:future_national_federation_event).name], 
      "Schedule should only show events sanctioned by Association"
    )
    
    assert_equal(
      ASSOCIATION.show_only_association_sanctioned_races_on_calendar?, 
      !html[events(:usa_cycling_event_with_results).name], 
      "Schedule page should honor ASSOCIATION.show_only_association_sanctioned_races_on_calendar?"
    )
  end
  
  def tets_road_index
    events = []
    year = 2006
    
    banana_belt = SingleDayEvent.new(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://#{STATIC_HOST}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    events << banana_belt
    banana_belt.save!
    
    mud_slinger = SingleDayEvent.new(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{STATIC_HOST}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Promoter.new(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :phone => "203-259-8577")
    )
    events << mud_slinger
    mud_slinger.save!

    get(:index, {:year => year, :discipline => "Road"})

    html = @response.body
    assert(!html["Mudslinger"], "Road events should not include MTB")
    assert(html["banana_belt.html"], "Schedule should include Banana Belt flyer URL")
  end
  
  def test_mtb_index
    events = []
    year = 2006
    
    banana_belt = SingleDayEvent.new(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://#{STATIC_HOST}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    events << banana_belt
    banana_belt.save!
    
    mud_slinger = SingleDayEvent.new(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{STATIC_HOST}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Promoter.new(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :phone => "203-259-8577")
    )
    events << mud_slinger
    mud_slinger.save!

    get(:index, {:year => year, :discipline => "Mountain Bike"})

    html = @response.body
    assert(html["Mudslinger"], "Road events should include MTB")
    assert(!html["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end
  
  def test_index_with_alias
    events = []
    year = 2006
    
    banana_belt = SingleDayEvent.new(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://#{STATIC_HOST}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    events << banana_belt
    banana_belt.save!
    
    mud_slinger = SingleDayEvent.new(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{STATIC_HOST}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Promoter.new(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :phone => "203-259-8577")
    )
    events << mud_slinger
    mud_slinger.save!

    get(:index, {:year => year, :discipline => "mountain_bike"})

    html = @response.body
    assert(html["Mudslinger"], "Road events should include MTB")
    assert(!html["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end
  
  def test_list
    get :list
    assert_response :success
  end
  
  def test_mtb_list
    events = []
    year = 2006
    
    banana_belt = SingleDayEvent.new(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://#{STATIC_HOST}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    events << banana_belt
    banana_belt.save!
    
    mud_slinger = SingleDayEvent.new(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{STATIC_HOST}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Promoter.new(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :phone => "203-259-8577")
    )
    events << mud_slinger
    mud_slinger.save!

    get(:list, {:year => year, :discipline => "Mountain Bike"})

    html = @response.body
    assert(html["Mudslinger"], "Road events should include MTB")
    assert(!html["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end
end
