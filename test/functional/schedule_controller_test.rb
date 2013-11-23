require File.expand_path("../../test_helper", __FILE__)

# :stopdoc:
class ScheduleControllerTest < ActionController::TestCase #:nodoc: all
  assert_no_angle_brackets :except => [ :test_index, :test_index_with_alias, :test_mtb_index ]
  
  def test_index
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:mtb_discipline)
    FactoryGirl.create(:number_issuer)

    year = 2006
    
    SingleDayEvent.create!(
      :name => "Banana Belt I",
      :city => "Hagg Lake",
      :date => Date.new(year, 1, 1),
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
    assert(html["Banana Belt I"], "'Banana Belt I' should be in HTML")
    assert(html["Mudslinger"], "'Mudslinger' should be in HTML")
    assert(html["banana_belt.html"], "Schedule should include Banana Belt flyer URL")
    assert(!html["mud_slinger.html"], "Schedule should not include Mudslinger flyer URL")
  end
  
  def test_index_only_shows_visible_events
    future_national_federation_event = FactoryGirl.create(:event, :sanctioned_by => "USA Cycling")
    
    get :index
    html = @response.body
    
    assert_equal(
      RacingAssociation.current.show_only_association_sanctioned_races_on_calendar?,
      !html[future_national_federation_event.name], 
      "Schedule should only show events sanctioned by Association"
    )
  end
  
  def test_index_rss
    FactoryGirl.create(:event)
    get :index, :format => :rss
    assert_redirected_to schedule_path(:format => :atom)
  end
  
  def test_index_atom
    FactoryGirl.create(:event)
    get :index, :format => :atom
    assert_response :success
  end
  
  def test_index_excel
    FactoryGirl.create(:event)
    get :index, :format => :xls
    assert_response :success
  end
  
  def test_index_excel_discipline
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:mtb_discipline)

    FactoryGirl.create(:event, :discipline => "Mountain Bike")

    get :index, :discipline => "mtb", :format => :xls
    assert_response :success
  end
  
  def test_index_excel_discipline_list
    FactoryGirl.create(:discipline)

    FactoryGirl.create(:event, :discipline => "Road")

    get :list, :discipline => "road", :format => :xls
    assert_response :success
  end
  
  def test_road_index
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
    FactoryGirl.create(:number_issuer)
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
  
  def test_filter_by_sanctioning_organization
    Timecop.freeze(2010, 2) do
      FactoryGirl.create(:event, :sanctioned_by => "FIAC", :name => "FIAC Event")
      FactoryGirl.create(:event, :sanctioned_by => "UCI", :name => "UCI Event")
      FactoryGirl.create(:event, :sanctioned_by => "CBRA", :name => "CBRA Event")
      racing_association = RacingAssociation.current
      racing_association.filter_schedule_by_sanctioning_organization = true
      racing_association.show_only_association_sanctioned_races_on_calendar = false
      racing_association.save!
    
      get :index
      html = @response.body
      assert html["FIAC Event"], "Should include FIAC event"
      assert html["UCI Event"], "Should include UCI event"
      assert html["CBRA Event"], "Should include CBRA event"
    end
  end
  
  def test_filter_by_sanctioning_organization_with_filter
    Timecop.freeze(2010, 2) do
      FactoryGirl.create(:event, :sanctioned_by => "FIAC", :name => "FIAC Event")
      FactoryGirl.create(:event, :sanctioned_by => "UCI", :name => "UCI Event")
      FactoryGirl.create(:event, :sanctioned_by => "CBRA", :name => "CBRA Event")
      racing_association = RacingAssociation.current
      racing_association.filter_schedule_by_sanctioning_organization = true
      racing_association.show_only_association_sanctioned_races_on_calendar = false
      racing_association.save!
    
      get :index, :sanctioning_organization => "FIAC"
      html = @response.body
      assert html["FIAC Event"], "Should include FIAC event"
      assert !html["UCI Event"], "Should not include UCI event"
      assert !html["CBRA Event"], "Should not include CBRA event"
    end
  end
  
  def test_filter_by_region
    Timecop.freeze(2010, 2) do
      racing_association = RacingAssociation.current
      racing_association.filter_schedule_by_region = true
      racing_association.save!

      wa = Region.create! :name => "Washington"
      oregon = Region.create! :name => "Oregon"
      Region.create! :name => "Northern California"

      FactoryGirl.create(:event, :region => wa, :name => "WA Event")
      FactoryGirl.create(:event, :region => oregon, :name => "OR Event")
    
      get :index, :region => "washington"
      html = @response.body
      assert html["WA Event"], "Should include Washington event"
      assert !html["OR Event"], "Should not include Oregon event"
    end
  end
  
  def test_index_with_alias
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:mtb_discipline)
    FactoryGirl.create(:number_issuer)

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

    get :index, :year => year, :discipline => "mountain_bike"

    html = @response.body
    assert(html["Mudslinger"], "mountain_bike should show MTB races")
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

  def test_list_excel_discipline
    FactoryGirl.create(:discipline)
    FactoryGirl.create(:event, :discipline => "Road")

    get :list, :discipline => "road", :format => :xls
    assert_response :success
  end

  def test_calendar_as_json
    get :index, :format => "json"
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

    get(:index, {:year => 2006, :discipline => "Mountain Bike", :format => "json"})

    json = @response.body
    assert(json["Mudslinger"], "Calendar should include MTB event")
    assert(!json["banana_belt.html"], "Schedule should not include Banana Belt flyer URL")
  end
end
