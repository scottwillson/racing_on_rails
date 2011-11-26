require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ScheduleControllerTest < ActionController::TestCase #:nodoc: all
  # if RacingAssociation.current.short_name == "mbra"
    assert_no_angle_brackets :except => [ :test_index, :test_index_with_alias, :test_mtb_index ]
  # end
  
  def test_index
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:mtb_discipline)

    year = 2006
    
    SingleDayEvent.create!(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    
    SingleDayEvent.create!(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Person.create!(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :home_phone => "203-259-8577")
    )
    
    SingleDayEvent.create!(:postponed => true)
    get(:index, {:year => year})

    html = @response.body
    Event.all.each do |event|
      assert(html[event.name], "'#{event.name}' should be in HTML")
    end
    assert(html["banana_belt.html"], "Schedule should include Banana Belt flyer URL")
    assert(!html["mud_slinger.html"], "Schedule should not include Mudslinger flyer URL")
  end
  
  def test_index_only_shows_visible_events
    future_national_federation_event = FactoryGirl.create(:event, :sanctioned_by => "USAC")
    
    get :index
    html = @response.body
    
    assert_equal(
      RacingAssociation.current.show_only_association_sanctioned_races_on_calendar?,
      !html[future_national_federation_event.name], 
      "Schedule should only show events sanctioned by Association"
    )
  end
  
  def tets_road_index
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:mtb_discipline)
    year = 2006
    
    SingleDayEvent.create!(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    
    SingleDayEvent.new(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Person.create!(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :home_phone => "203-259-8577")
    )

    get(:index, {:year => year, :discipline => "Road"})

    html = @response.body
    assert(!html["Mudslinger"], "Road events should not include MTB")
    assert(html["banana_belt.html"], "Schedule should include Banana Belt flyer URL")
  end
  
  def test_mtb_index
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:mtb_discipline)
    year = 2006
    
    SingleDayEvent.create!(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    
    SingleDayEvent.create!(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Person.create!(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :home_phone => "203-259-8577")
    )

    get(:index, {:year => year, :discipline => "Mountain Bike"})

    html = @response.body
    assert(html["Mudslinger"], "Road events should include MTB")
    assert(!html["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end
  
  def test_index_with_alias
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:mtb_discipline)
    
    year = 2006
    
    SingleDayEvent.create!(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    
    SingleDayEvent.create!(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Person.create!(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :home_phone => "203-259-8577")
    )

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
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:mtb_discipline)

    year = 2006
    
    SingleDayEvent.create!(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 22),
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )
    
    SingleDayEvent.create!(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(year, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Person.create!(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :home_phone => "203-259-8577")
    )

    get(:list, {:year => year, :discipline => "Mountain Bike"})

    html = @response.body
    assert(html["Mudslinger"], "Road events should include MTB")
    assert(!html["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end

  def test_calendar_as_json
    get :calendar, :format => "json"
    assert_response :success
  end

  def test_mtb_calendar_as_json
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:mtb_discipline)
    SingleDayEvent.create!(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(2006, 1, 22),
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/banana_belt.html",
      :flyer_approved => true
    )

    SingleDayEvent.create!(
      :name => "Mudslinger",
      :city => "Blodgett",
      :date => Date.new(2006, 12, 27),
      :discipline => "Mountain Bike",
      :flyer => "http://#{RacingAssociation.current.static_host}/flyers/2005/mud_slinger.html",
      :flyer_approved => false,
      :promoter => Person.create!(:name => "Mike Ripley", :email => "mikecycle@earthlink.net", :home_phone => "203-259-8577")
    )

    get(:calendar, {:year => 2006, :discipline => "Mountain Bike", :format => "json"})

    json = @response.body
    assert(json["Mudslinger"], "Calendar should include MTB event")
    assert(!json["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end
end
