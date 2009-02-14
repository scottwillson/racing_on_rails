# :stopdoc:
require File.dirname(__FILE__) + '/../../test_helper'

class Admin::EventsControllerTest < ActionController::TestCase

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::CaptureHelper

  def setup
    super
    @request.session[:user] = users(:candi)
  end

  def test_edit
    banana_belt = events(:banana_belt_1)
    banana_belt.velodrome = velodromes(:trexlertown)
    banana_belt.save!
    
    get(:edit, :id => banana_belt.to_param)
    assert_response(:success)
    assert_template("admin/events/edit")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
    assert(!@response.body["#&lt;Velodrome:"], "Should not have model in text field")
  end

  def test_edit_parent
    banana_belt = events(:banana_belt_series)

    get(:edit, :id => banana_belt.to_param)
    assert_response(:success)
    assert_template("admin/events/edit")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
  end

  def test_edit_no_results
    mt_hood_1 = events(:mt_hood_1)

    get(:edit, :id => mt_hood_1.to_param)
    assert_response(:success)
    assert_template("admin/events/edit")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
  end

  def test_edit_with_standings
    kings_valley = events(:kings_valley)
    standings = kings_valley.standings.first

    get(:edit, :id => kings_valley.to_param, :standings_id => standings.to_param)
    assert_response(:success)
    assert_template("admin/events/edit")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
  end

  def test_edit_with_promoter
    banana_belt = events(:banana_belt_1)
    opts = {:controller => "admin/events", :action => "edit", :id => banana_belt.to_param, :promoter_id => '2'}
    assert_recognizes(opts, "/admin/events/#{banana_belt.to_param}/edit", :promoter_id => '2')
    
    assert_not_equal(promoters(:candi_murray), banana_belt.promoter, 'Promoter before edit with promoter ID')

    get(:edit, :id => banana_belt.to_param)
    assert_response(:success)
    assert_template("admin/events/edit")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
    assert_not_equal(promoters(:candi_murray), assigns["event"].promoter, 'Promoter from promoter ID')
  end

  def test_upload
    mt_hood_1 = events(:mt_hood_1)
    assert(mt_hood_1.standings.empty?, 'Should have no standings before import')

    post :upload, :id => mt_hood_1.to_param, :results_file => fixture_file_upload("results/pir_2006_format.xls")

    assert(!flash.has_key?(:warn), "flash[:warn] should be empty,  but was: #{flash[:warn]}")
    assert_response :redirect
    assert_redirected_to(:action => :edit, :id => mt_hood_1.to_param, :standings_id => mt_hood_1.standings(true).last.to_param)
    assert(flash.has_key?(:notice))
    assert(!mt_hood_1.standings(true).empty?, 'Should have standings after upload attempt')
  end

  def test_upload_invalid_columns
    mt_hood_1 = events(:mt_hood_1)
    assert(mt_hood_1.standings.empty?, 'Should have no standings before import')
    
    post :upload, :id => mt_hood_1.to_param, :results_file => fixture_file_upload("results/invalid_columns.xls")
    assert_redirected_to(:action => :edit, :id => mt_hood_1.to_param, :standings_id => mt_hood_1.standings(true).last.to_param)

    assert_response :redirect
    assert(flash.has_key?(:notice))
    assert(flash.has_key?(:warn))
    assert(!mt_hood_1.standings(true).empty?, 'Should have standings after upload attempt')
  end
  
  def test_new_single_day_event
    get(:new, :year => '2008')
    assert_response(:success)
    assert_template('admin/events/edit')
    assert_not_nil(assigns["event"], "Should assign event")
  end

  def test_new_single_day_event_default_year
    get(:new)
    assert_response(:success)
    assert_template('admin/events/edit')
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(Date.today.year, assigns["event"].date.year)
  end
  
  def test_create_event
    assert_nil(Event.find_by_name('Skull Hollow Roubaix'), 'Skull Hollow Roubaix should not be in DB')

    post(:create, 
         "commit"=>"Save", 
         "event"=>{"city"=>"Smith Rock", "name"=>"Skull Hollow Roubaix","date"=>"2010-01-02",
                   "flyer"=>"http://timplummer.org/roubaix.html", "sanctioned_by"=>"WSBA", "flyer_approved"=>"1", 
                   "discipline"=>"Downhill", "cancelled"=>"1", "state"=>"KY",
                  'promoter_id' => promoters(:nate_hobson).to_param, 'type' => 'SingleDayEvent'}
    )
    
    skull_hollow = Event.find_by_name('Skull Hollow Roubaix')
    assert_not_nil(skull_hollow, 'Skull Hollow Roubaix should be in DB')
    assert(skull_hollow.is_a?(SingleDayEvent), 'Skull Hollow should be a SingleDayEvent')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :new)
    assert(flash.has_key?(:notice))

    assert_equal('Skull Hollow Roubaix', skull_hollow.name, 'name')
    assert_equal('Smith Rock', skull_hollow.city, 'city')
    assert_equal(Date.new(2010, 1, 2), skull_hollow.date, 'date')
    assert_equal('http://timplummer.org/roubaix.html', skull_hollow.flyer, 'flyer')
    assert_equal('WSBA', skull_hollow.sanctioned_by, 'sanctioned_by')
    assert_equal(true, skull_hollow.flyer_approved, 'flyer_approved')
    assert_equal('Downhill', skull_hollow.discipline, 'discipline')
    assert_equal(true, skull_hollow.cancelled, 'cancelled')
    assert_equal('KY', skull_hollow.state, 'state')
    assert_equal(promoters(:nate_hobson), skull_hollow.promoter, 'promoter')
  end
  
  def test_create_series
    assert_nil(Event.find_by_name('Skull Hollow Roubaix'), 'Skull Hollow Roubaix should not be in DB')

    post(:create, 
         "commit"=>"Save", 
         "event"=>{"city"=>"Smith Rock", "name"=>"Skull Hollow Roubaix","date"=>"2010-01-02",
                   "flyer"=>"http://timplummer.org/roubaix.html", "sanctioned_by"=>"WSBA", "flyer_approved"=>"1", 
                   "discipline"=>"Downhill", "cancelled"=>"1", "state"=>"KY",
                  "promoter_id"  => promoters(:nate_hobson).to_param, 'type' => 'Series'}
    )
    
    skull_hollow = Event.find_by_name('Skull Hollow Roubaix')
    assert_not_nil(skull_hollow, 'Skull Hollow Roubaix should be in DB')
    assert(skull_hollow.is_a?(Series), 'Skull Hollow should be a series')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :new)
  end
  
  def test_create_from_events
    lost_child = SingleDayEvent.create!(:name => "Alameda Criterium")
    SingleDayEvent.create!(:name => "Alameda Criterium")
    opts = {:controller => "admin/events", :action => "create_from_events", :id => lost_child.to_param}
    assert_routing("/admin/events/create_from_events/#{lost_child.id}", opts)
    
    post(:create_from_events, :id => lost_child.to_param)

    assert_response(:redirect)
    new_parent = MultiDayEvent.find_by_name(lost_child.name)
    assert_redirected_to(:action => :edit, :id => new_parent.to_param)
  end
  
  def test_upload_dupe_racers
    # Two racers with different name, same numbers
    # Excel file has Greg Rodgers with no number
    Racer.create(:name => 'Greg Rodgers', :road_number => '404')
    Racer.create(:name => 'Greg Rodgers', :road_number => '500')
    
    mt_hood_1 = events(:mt_hood_1)
    assert(mt_hood_1.standings(true).empty?, 'Should have no standings before import')
    
    file = uploaded_file("/test/fixtures/results/dupe_racers.xls", "dupe_racers.xls", "application/vnd.ms-excel")
    post :upload, :id => mt_hood_1.to_param, :results_file => file
    
    assert_response :redirect
    
    # Dupe racers used to be allowed, and this would have been an error
    assert(!mt_hood_1.standings(true).empty?, 'Should have standings after importing dupe racers')
    assert(!flash.has_key?(:warn))
  end

  def test_destroy_event
    jack_frost = events(:jack_frost)
    delete(:destroy, :id => jack_frost.id, :commit => 'Delete')
    assert_redirected_to(admin_events_path(:year => jack_frost.date.year))
    assert(!Event.exists?(jack_frost.id), "Jack Frost should have been destroyed")
  end

  def test_update_event
    banana_belt = events(:banana_belt_1)

    assert_not_equal('Banana Belt One', banana_belt.name, 'name')
    assert_not_equal('Forest Grove', banana_belt.city, 'city')
    assert_not_equal('Geoff Mitchem', banana_belt.promoter_name, 'promoter_name')
    assert_not_equal(Date.new(2006, 03, 12), banana_belt.date, 'date')
    assert_not_equal('../../flyers/2006/banana_belt.html', banana_belt.flyer, 'flyer')
    assert_not_equal('UCI', banana_belt.sanctioned_by, 'sanctioned_by')
    assert_not_equal(true, banana_belt.flyer_approved, 'flyer_approved')
    assert_not_equal('503-233-3636', banana_belt.promoter_phone, 'promoter_phone')
    assert_not_equal('JMitchem@ffadesign.com', banana_belt.promoter_email, 'promoter_email')
    assert_not_equal('Track', banana_belt.discipline, 'discipline')
    assert_not_equal(true, banana_belt.cancelled, 'cancelled')
    assert_not_equal('OR', banana_belt.state, 'state')
    norba = NumberIssuer.create!(:name => 'NORBA')
    assert_not_equal(norba, banana_belt.number_issuer, 'number_issuer')

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.to_param,
         "event"=>{"city"=>"Forest Grove", "name"=>"Banana Belt One","date"=>"2006-03-12",
                   "flyer"=>"../../flyers/2006/banana_belt.html", "sanctioned_by"=>"UCI", "flyer_approved"=>"1", 
                   "discipline"=>"Track", "cancelled"=>"1", "state"=>"OR",
                  "promoter_id" => promoters(:brad_ross).to_param, 'number_issuer_id' => norba.to_param}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => banana_belt.to_param)

    banana_belt.reload
    assert_equal('Banana Belt One', banana_belt.name, 'name')
    assert_equal('Forest Grove', banana_belt.city, 'city')
    assert_equal(Date.new(2006, 03, 12), banana_belt.date, 'date')
    assert_equal("http://#{STATIC_HOST}/flyers/2006/banana_belt.html", banana_belt.flyer, 'flyer')
    assert_equal('UCI', banana_belt.sanctioned_by, 'sanctioned_by')
    assert_equal(true, banana_belt.flyer_approved, 'flyer_approved')
    assert_equal('Track', banana_belt.discipline, 'discipline')
    assert_equal(true, banana_belt.cancelled, 'cancelled')
    assert_equal('OR', banana_belt.state, 'state')
    assert_equal('Brad Ross', banana_belt.promoter_name, 'promoter_name')
    assert_nil(banana_belt.promoter_phone, 'promoter_phone')
    assert_nil(banana_belt.promoter_email, 'promoter_email')
    assert_equal(norba, banana_belt.number_issuer, 'number_issuer')
  end

  def test_save_no_promoter
    assert_nil(SingleDayEvent.find_by_name('Silverton'), 'Silverton should not be in database')
    # New event, no changes, single day, no promoter
    post(:create, 
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>"Silverton",
                  'type' => 'SingleDayEvent',
                  'promoter_id' => ""}
    )
    assert_response(:redirect)
    silverton = SingleDayEvent.find_by_name('Silverton')
    assert_not_nil(silverton, 'Silverton should be in database')
    assert(!silverton.new_record?, "Silverton should be saved")
    assert_nil(silverton.promoter, "Silverton Promoter")
    assert_redirected_to(:action => :new)
  end
  
  def test_save_different_promoter
    banana_belt = events(:banana_belt_1)
    assert_equal(promoters(:brad_ross), banana_belt.promoter, 'Promoter before save')
    
    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.to_param,
         "event"=>{"city"=>"Forest Grove", "name"=>"Banana Belt One","date"=>"2006-03-12",
                   "flyer"=>"../../flyers/2006/banana_belt.html", "sanctioned_by"=>"UCI", "flyer_approved"=>"1", 
                   "discipline"=>"Track", "cancelled"=>"1", "state"=>"OR", 'type' => 'SingleDayEvent',
                  "promoter_id"  => promoters(:nate_hobson).to_param}
    )
    assert_nil(flash[:warn], 'flash[:warn]')
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => banana_belt.to_param)
    
    banana_belt.reload
    assert_equal(promoters(:nate_hobson), banana_belt.promoter(true), 'Promoter after save')
  end
  
  def test_update_single_day_to_multi_day
    for type in [MultiDayEvent, Series, WeeklySeries]
      event = events(:banana_belt_1)

      post(:update, 
           "commit"=>"Save", 
           :id => event.to_param,
           "event"=>{"city"=>"Forest Grove", "name"=>"Banana Belt One","date"=>"2006-03-12",
                     "flyer"=>"../../flyers/2006/banana_belt.html", "sanctioned_by"=>"UCI", 
                     "flyer_approved"=>"1", 
                     "discipline"=>"Track", "cancelled"=>"1", "state"=>"OR",
                     "promoter_id" => promoters(:nate_hobson).to_param, 
                     'number_issuer_id' => number_issuers(:stage_race).to_param,
                     'type' => type.to_s}
      )
      assert_response(:redirect)
      assert_redirected_to(:action => :edit, :id => event.to_param)
      event = Event.find(event.id)
      assert(event.is_a?(type), "#{event.name} should be a #{type}")
    end
  end
  
  def test_update_multi_day_to_single_day
    event = events(:mt_hood)
    original_attributes = event.attributes.clone

    post(:update, 
         "commit"=>"Save", 
         :id => event.to_param,
         "event"=>{"city"=>event.city, "name"=>"Mt. Hood One Day","date"=>event.date,
                   "flyer"=>event.flyer, "sanctioned_by"=>event.sanctioned_by, "flyer_approved"=> event.flyer_approved, 
                   "discipline"=>event.discipline, "cancelled"=>event.cancelled, "state"=>event.state,
                  'promoter_id' => event.promoter_id, 'number_issuer_id' => event.number_issuer_id, 'type' => 'SingleDayEvent'}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => event.to_param)
    event = Event.find(event.id)
    assert(event.is_a?(SingleDayEvent), "Mt Hood should be a SingleDayEvent")

    assert_nil(events(:mt_hood_1).parent(true), "Original child's parent")
    assert_nil(events(:mt_hood_2).parent(true), "Original child's parent")

    assert_equal("Mt. Hood One Day", event.name, 'name')
    assert_equal(original_attributes["date"], event.date, 'date')
    assert_equal(original_attributes["flyer"], event.flyer, 'flyer')
    assert_equal(original_attributes["sanctioned_by"], event.sanctioned_by, 'sanctioned_by')
    assert_equal(original_attributes["flyer_approved"], event.flyer_approved, 'flyer_approved')
    assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
    assert_equal(original_attributes["cancelled"], event.cancelled, 'cancelled')
    assert_equal(original_attributes["state"], event.state, 'state')
    assert_equal(original_attributes["promoter_id"], event.promoter_id, 'promoter_id')
    assert_equal(original_attributes["number_issuer_id"], event.number_issuer_id, 'number_issuer_id')
    assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
  end
  
  # MultiDayEvent -> Series
  def test_update_multi_day_to_series
    event = events(:mt_hood)
    original_attributes = event.attributes.clone

    post(:update, 
         "commit"=>"Save", 
         :id => event.to_param,
         "event"=>{"city"=>event.city, "name"=>"Mt. Hood Series","date"=>event.date,
                   "flyer"=>event.flyer, "sanctioned_by"=>event.sanctioned_by, "flyer_approved"=> event.flyer_approved, 
                   "discipline"=>event.discipline, "cancelled"=>event.cancelled, "state"=>event.state,
                  'promoter_id' => event.promoter_id, 'number_issuer_id' => event.number_issuer_id, 'type' => 'Series'}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => event.to_param)
    event = Event.find(event.id)
    assert(event.is_a?(Series), "Mt Hood should be a Series")

    assert_equal(event, events(:mt_hood_1).parent(true), "Original child's parent")
    assert_equal(event, events(:mt_hood_2).parent(true), "Original child's parent")

    assert_equal("Mt. Hood Series", event.name, 'name')
    assert_equal(original_attributes["date"], event.date, 'date')
    assert_equal(original_attributes["flyer"], event.flyer, 'flyer')
    assert_equal(original_attributes["sanctioned_by"], event.sanctioned_by, 'sanctioned_by')
    assert_equal(original_attributes["flyer_approved"], event.flyer_approved, 'flyer_approved')
    assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
    assert_equal(original_attributes["cancelled"], event.cancelled, 'cancelled')
    assert_equal(original_attributes["state"], event.state, 'state')
    assert_equal(original_attributes["promoter_id"], event.promoter_id, 'promoter_id')
    assert_equal(original_attributes["number_issuer_id"], event.number_issuer_id, 'number_issuer_id')
    assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
  end
  
  # MultiDayEvent -> WeeklySeries
  def test_update_multi_day_to_weekly_series
    event = events(:mt_hood)
    original_attributes = event.attributes.clone

    post(:update, 
         "commit"=>"Save", 
         :id => event.to_param,
         "event"=>{"city"=>event.city, "name"=>"Mt. Hood Series","date"=>event.date,
                   "flyer"=>event.flyer, "sanctioned_by"=>event.sanctioned_by, "flyer_approved"=> event.flyer_approved, 
                   "discipline"=>event.discipline, "cancelled"=>event.cancelled, "state"=>event.state,
                  'promoter_id' => event.promoter_id, 'number_issuer_id' => event.number_issuer_id, 'type' => 'WeeklySeries'}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => event.to_param)
    event = Event.find(event.id)
    assert(event.is_a?(WeeklySeries), "Mt Hood should be a WeeklySeries")

    assert_equal(event, events(:mt_hood_1).parent(true), "Original child's parent")
    assert_equal(event, events(:mt_hood_2).parent(true), "Original child's parent")

    assert_equal("Mt. Hood Series", event.name, 'name')
    assert_equal(original_attributes["date"], event.date, 'date')
    assert_equal(original_attributes["flyer"], event.flyer, 'flyer')
    assert_equal(original_attributes["sanctioned_by"], event.sanctioned_by, 'sanctioned_by')
    assert_equal(original_attributes["flyer_approved"], event.flyer_approved, 'flyer_approved')
    assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
    assert_equal(original_attributes["cancelled"], event.cancelled, 'cancelled')
    assert_equal(original_attributes["state"], event.state, 'state')
    assert_equal(original_attributes["promoter_id"], event.promoter_id, 'promoter_id')
    assert_equal(original_attributes["number_issuer_id"], event.number_issuer_id, 'number_issuer_id')
    assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
  end
  
  def test_update_series_to_weekly_series
    event = events(:banana_belt_series)
    original_attributes = event.attributes.clone

    post(:update, 
         "commit"=>"Save", 
         :id => event.to_param,
         "event"=>{"city"=>event.city, "name"=>"BB Weekly Series","date"=>event.date,
                   "flyer"=>event.flyer, "sanctioned_by"=>event.sanctioned_by, "flyer_approved"=> event.flyer_approved, 
                   "discipline"=>event.discipline, "cancelled"=>event.cancelled, "state"=>event.state,
                  'promoter_id' => event.promoter_id, 'number_issuer_id' => event.number_issuer_id, 'type' => 'WeeklySeries'}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => event.to_param)
    event = Event.find(event.id)
    assert(event.is_a?(WeeklySeries), "BB should be a WeeklySeries")

    assert_equal(event, events(:banana_belt_1).parent(true), "Original child's parent")
    assert_equal(event, events(:banana_belt_2).parent(true), "Original child's parent")

    assert_equal("BB Weekly Series", event.name, 'name')
    assert_equal(original_attributes["date"], event.date, 'date')
    assert_equal(original_attributes["flyer"], event.flyer, 'flyer')
    assert_equal(original_attributes["sanctioned_by"], event.sanctioned_by, 'sanctioned_by')
    assert_equal(original_attributes["flyer_approved"], event.flyer_approved, 'flyer_approved')
    assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
    assert_equal(original_attributes["cancelled"], event.cancelled, 'cancelled')
    assert_equal(original_attributes["state"], event.state, 'state')
    assert_equal(original_attributes["promoter_id"], event.promoter_id, 'promoter_id')
    assert_equal(original_attributes["number_issuer_id"], event.number_issuer_id, 'number_issuer_id')
    assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
  end
  
  def test_update_weekly_series_to_single_day
    event = events(:pir_series)
    original_attributes = event.attributes.clone

    post(:update, 
         "commit"=>"Save", 
         :id => event.to_param,
         "event"=>{"city"=>event.city, "name"=>"PIR One Day","date"=>event.date,
                   "flyer"=>event.flyer, "sanctioned_by"=>event.sanctioned_by, "flyer_approved"=> event.flyer_approved, 
                   "discipline"=>event.discipline, "cancelled"=>event.cancelled, "state"=>event.state,
                  'promoter_id' => event.promoter_id, 'number_issuer_id' => event.number_issuer_id, 'type' => 'SingleDayEvent'}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => event.to_param)
    event = Event.find(event.id)
    assert(event.is_a?(SingleDayEvent), "PIR should be a SingleDayEvent")

    assert_nil(events(:pir).parent(true), "Original child's parent")
    assert_nil(events(:pir_2).parent(true), "Original child's parent")

    assert_equal("PIR One Day", event.name, 'name')
    assert_equal(original_attributes["date"], event.date, 'date')
    assert_equal(original_attributes["flyer"], event.flyer, 'flyer')
    assert_equal(original_attributes["sanctioned_by"], event.sanctioned_by, 'sanctioned_by')
    assert_equal(original_attributes["flyer_approved"], event.flyer_approved, 'flyer_approved')
    assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
    assert_equal(original_attributes["cancelled"], event.cancelled, 'cancelled')
    assert_equal(original_attributes["state"], event.state, 'state')
    assert_equal(original_attributes["promoter_id"], event.promoter_id, 'promoter_id')
    assert_equal(original_attributes["number_issuer_id"], event.number_issuer_id, 'number_issuer_id')
    assert_equal(original_attributes["discipline"], event.discipline, 'discipline')
  end
  
  def test_set_parent
    event = events(:lost_series_child)
    assert_nil(event.parent)
    
    parent = events(:series_parent)
    post(:set_parent, :parent_id => parent, :child_id => event)
    
    event.reload
    assert_equal(parent, event.parent)
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => event)
  end
  
  def test_missing_parent
    event = events(:lost_series_child)
    assert(event.missing_parent?, "Event should be missing parent")
    get(:edit, :id => event.to_param)
    assert_response(:success)
    assert_template("admin/events/edit")
  end
  
  def test_missing_children
    event = events(:series_parent)
    assert(event.missing_children?, "Event should be missing children")
    assert_not_nil(event.missing_children, "Event should be missing children")
    get(:edit, :id => event.to_param)
    assert_response(:success)
    assert_template("admin/events/edit")
  end
  
  def test_multi_day_event_children_with_no_parent
    SingleDayEvent.create!(:name => "PIR Short Track")
    SingleDayEvent.create!(:name => "PIR Short Track")
    SingleDayEvent.create!(:name => "PIR Short Track")
    event = SingleDayEvent.create!(:name => "PIR Short Track")

    assert(event.multi_day_event_children_with_no_parent?, "multi_day_event_children_with_no_parent?")
    assert_not_nil(event.multi_day_event_children_with_no_parent, "multi_day_event_children_with_no_parent")
    assert(!(event.multi_day_event_children_with_no_parent).empty?, "multi_day_event_children_with_no_parent")
    get(:edit, :id => event.to_param)
    assert_response(:success)
    assert_template("admin/events/edit")
  end
  
  def test_add_children
    event = events(:series_parent)
    post(:add_children, :parent_id => event.to_param)
    assert_redirected_to(:action => :edit, :id => event.to_param)
  end

  def test_index
    get(:index, :year => "2004")
    assert_response(:success)
    assert_template("admin/events/index")
    assert_not_nil(assigns["schedule"], "Should assign schedule")
  end
  
  def test_not_logged_in
    @request.session[:user] = nil
    get(:index, :year => "2004")
    assert_response(:redirect)
    assert_redirected_to(:controller => '/admin/account', :action => 'login')
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_links_to_years
    get(:index, :year => "2004")

    link = @response.body["href=\"/admin/events?year=2003"]
    obra_link = @response.body["/schedule/2003"]
    assert(link || obra_link, "Should link to 2003 in:\n#{@response.body}")

    link = @response.body["href=\"/admin/events?year=2005"]
    obra_link = @response.body["/schedule/2005"]
    assert(link || obra_link, "Should link to 2005 in:\n#{@response.body}")
  end

  def test_links_to_years_only_past_year_has_events
    Event.delete_all
    current_year = Date.today.year
    last_year = current_year - 1
    SingleDayEvent.create!(:date => Date.new(last_year))
    
    get(:index, :year => current_year)
    assert_match("href=\"/admin/events?year=#{last_year}", @response.body, "Should link to #{last_year} in:\n#{@response.body}")
    assert_match("href=\"/admin/events\"", @response.body, "Should link to #{current_year} in:\n#{@response.body}")
  end

  def test_upload_schedule
    @request.session[:user] = users(:candi)

    before_import_after_schedule_start_date = Event.count(:conditions => "date > '2005-01-01'")
    assert_equal(11, before_import_after_schedule_start_date, "2005 events count before import")
    before_import_all = Event.count
    assert_equal(19, before_import_all, "All events count before import")

    post(:upload_schedule, :schedule_file => fixture_file_upload("schedule.xls"))

    assert(!flash.has_key?(:warn), "flash[:warn] should be empty,  but was: #{flash[:warn]}")
    assert_response :redirect
    assert_redirected_to(admin_events_path)
    assert(flash.has_key?(:notice))

    after_import_after_schedule_start_date = Event.count(:conditions => "date > '2005-01-01'")
    assert_equal(84, after_import_after_schedule_start_date, "2005 events count after import")
    after_import_all = Event.count
    assert_equal(92, after_import_all, "All events count after import")
  end
end
