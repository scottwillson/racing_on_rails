require File.dirname(__FILE__) + '/../../test_helper'
require_or_load 'admin/events_controller'

# :stopdoc:
# Re-raise errors caught by the controller.
class Admin::EventsController; def rescue_action(e) raise e end; end

class Admin::EventsControllerTest < Test::Unit::TestCase

  fixtures :promoters, :events, :aliases_disciplines, :disciplines, :users
  include ApplicationHelper

  def setup
    @controller = Admin::EventsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_show_parent
    @request.session[:user] = users(:candi)
    banana_belt = events(:banana_belt_series)
    opts = {:controller => "admin/events", :action => "show", :id => banana_belt.to_param.to_s}
    assert_routing("/admin/events/#{banana_belt.to_param}", opts)
    
    get(:show, :id => banana_belt.to_param.to_s)
    assert_response(:success)
    assert_template("admin/events/show")
    assert_not_nil(assigns["event"], "Should assign event")
    assert_nil(assigns["race"], "Should not assign race")
  end

  def test_new_single_day_event
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/events", :action => "new", :year => '2008'}
    assert_routing("/admin/events/new/2008", opts)
    get(:new, :year => '2008')
    assert_response(:success)
    assert_template('admin/events/new')
    assert_not_nil(assigns["event"], "Should assign event")
  end

  def test_new_single_day_event_default_year
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/events", :action => "new"}
    assert_generates("/admin/events/new", opts)
    get(:new)
    assert_response(:success)
    assert_template('admin/events/new')
    assert_not_nil(assigns["event"], "Should assign event")
    assert_equal(Date.today.year, assigns["event"].date.year)
  end
  
  def test_create_event
    @request.session[:user] = users(:candi)

    opts = {:controller => "admin/events", :action => "create"}
    assert_routing("/admin/events/create", opts)

    assert_nil(Event.find_by_name('Skull Hollow Roubaix'), 'Skull Hollow Roubaix should not be in DB')

    post(:create, 
         "commit"=>"Save", 
         "event"=>{"city"=>"Smith Rock", "name"=>"Skull Hollow Roubaix","date"=>"2010-01-02",
                   "flyer"=>"http://timplummer.org/roubaix.html", "sanctioned_by"=>"WSBA", "flyer_approved"=>"1", 
                   "discipline"=>"Downhill", "cancelled"=>"1", "state"=>"KY",
                  'promoter' => {"name"=>"Tim Plummer",  "phone"=>"503-913-7676", "email"=>"tplummer@gmail.com"}}
    )
    
    skull_hollow = Event.find_by_name('Skull Hollow Roubaix')
    assert_not_nil(skull_hollow, 'Skull Hollow Roubaix should be in DB')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => skull_hollow.to_param)

    assert_equal('Skull Hollow Roubaix', skull_hollow.name, 'name')
    assert_equal('Smith Rock', skull_hollow.city, 'city')
    assert_equal(Date.new(2010, 1, 2), skull_hollow.date, 'date')
    assert_equal('http://timplummer.org/roubaix.html', skull_hollow.flyer, 'flyer')
    assert_equal('WSBA', skull_hollow.sanctioned_by, 'sanctioned_by')
    assert_equal(true, skull_hollow.flyer_approved, 'flyer_approved')
    assert_equal('Downhill', skull_hollow.discipline, 'discipline')
    assert_equal(true, skull_hollow.cancelled, 'cancelled')
    assert_equal('KY', skull_hollow.state, 'state')
    assert_equal('Tim Plummer', skull_hollow.promoter_name, 'promoter_name')
    assert_equal('503-913-7676', skull_hollow.promoter_phone, 'promoter_phone')
    assert_equal('tplummer@gmail.com', skull_hollow.promoter_email, 'promoter_email')
  end
  
  def test_update_event
    @request.session[:user] = users(:candi)
    banana_belt = events(:banana_belt_1)
    opts = {:controller => "admin/events", :action => "update", :id => banana_belt.to_param.to_s}
    assert_routing("/admin/events/update/#{banana_belt.to_param}", opts)

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

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.to_param.to_s,
         "event"=>{"city"=>"Forest Grove", "name"=>"Banana Belt One","date"=>"2006-03-12",
                   "flyer"=>"../../flyers/2006/banana_belt.html", "sanctioned_by"=>"UCI", "flyer_approved"=>"1", 
                   "discipline"=>"Track", "cancelled"=>"1", "state"=>"OR",
                  'promoter' => {"name"=>"Geoff Mitchem",  "phone"=>"503-233-3636", "email"=>"JMitchem@ffadesign.com"}}
    )
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => banana_belt.to_param.to_s)

    banana_belt.reload
    assert_equal('Banana Belt One', banana_belt.name, 'name')
    assert_equal('Forest Grove', banana_belt.city, 'city')
    assert_equal(Date.new(2006, 03, 12), banana_belt.date, 'date')
    assert_equal('../../flyers/2006/banana_belt.html', banana_belt.flyer, 'flyer')
    assert_equal('UCI', banana_belt.sanctioned_by, 'sanctioned_by')
    assert_equal(true, banana_belt.flyer_approved, 'flyer_approved')
    assert_equal('Track', banana_belt.discipline, 'discipline')
    assert_equal(true, banana_belt.cancelled, 'cancelled')
    assert_equal('OR', banana_belt.state, 'state')
    assert_equal('Geoff Mitchem', banana_belt.promoter_name, 'promoter_name')
    assert_equal('503-233-3636', banana_belt.promoter_phone, 'promoter_phone')
    assert_equal('JMitchem@ffadesign.com', banana_belt.promoter_email, 'promoter_email')
  end

  def test_update_error
    @request.session[:user] = users(:candi)
    banana_belt = events(:banana_belt_1)
    opts = {:controller => "admin/events", :action => "update", :id => banana_belt.to_param.to_s}
    assert_routing("/admin/events/update/#{banana_belt.to_param}", opts)

    assert_equal('Banana Belt I', banana_belt.name, 'name')

    post(:update, 
         "commit"=>"Save", 
         :id => banana_belt.to_param.to_s,
         "event"=>{"city"=>"Forest Grove", "name"=>"", "promoter_name"=>"Geoff Mitchem", "date"=>"99822sasa!",
                   "flyer"=>"../../flyers/2006/banana_belt.html", "sanctioned_by"=>"OBRA", "flyer_approved"=>"1", "promoter_phone"=>"503-233-3636", 
                  "promoter_email"=>"JMitchem@ffadesign.com", "discipline"=>"Road", "cancelled"=>"1", "state"=>"OR"}
    )
    assert_response(:success)
    assert_template("admin/events/show")
    assert_not_nil(assigns['event'], 'Should assign event')
    assert_not_nil(flash[:warn], "Should have warning after invalid update")
    banana_belt.reload
    assert_equal('Banana Belt I', banana_belt.name, 'name')
  end
  
  def test_save_new_single_day_no_promoter
    assert_nil(SingleDayEvent.find_by_name('Silverton'), 'Silverton should not be in database')
    # New event, no changes, single day, no promoter
    @request.session[:user] = users(:candi)
    post(:create, 
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>"Silverton",
                  'promoter' => {"name"=>"",  "phone"=>"", "email"=>""}}
    )
    assert_response(:redirect)
    silverton = SingleDayEvent.find_by_name('Silverton')
    assert_not_nil(silverton, 'Silverton should be in database')
    assert(!silverton.new_record?, "Silverton should be saved")
    assert_nil(silverton.promoter, "Silverton Promoter")
    assert_redirected_to(:action => :show, :id => silverton.to_param)
  end
  
  def test_save_new_single_day_existing_promoter
    candi_murray = promoters(:candi_murray)
    email = candi_murray.email
    phone = candi_murray.phone
  
    @request.session[:user] = users(:candi)
    post(:create, 
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>"Silverton",
                  'promoter' => {"name" => candi_murray.name,  "phone"=>"", "email"=>""}}
    )
    
    silverton = SingleDayEvent.find_by_name('Silverton')
    assert_equal(candi_murray, silverton.promoter, "Silverton Promoter")
    assert_equal("", silverton.promoter.email, "Silverton promoter email should be blank")
    assert_equal("", silverton.promoter.phone, "Silverton promoter phone should be blank")
  end
  
  def test_save_new_single_day_existing_promoter_different_info_overwrite
    candi_murray = promoters(:candi_murray)
    new_email = "scout@scout_promotions.net"
    new_phone = "123123"

    @request.session[:user] = users(:candi)
    post(:create, 
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>"Silverton",
                  'promoter' => {"name" => candi_murray.name,  "phone"=> new_phone, "email"=> new_email}}
    )
    
    silverton = SingleDayEvent.find_by_name('Silverton')
    assert_equal(candi_murray, silverton.promoter, "Silverton Promoter")
    assert_equal(new_email, silverton.promoter.email, "Promoter email")
    assert_equal(new_phone, silverton.promoter.phone, "Promoter phone")
  end
  
  def test_save_new_single_day_existing_promoter_different_info_do_not_overwrite
    candi_murray = promoters(:candi_murray)
    old_name = candi_murray.name
    old_email = candi_murray.email
    old_phone = candi_murray.phone

    @request.session[:user] = users(:candi)
    post(:create, 
         "commit"=>"Save", 
         'same_promoter' => 'false',
         "event"=>{"name"=>"Silverton",
                  'promoter' => {"name" => candi_murray.name,  "phone"=> "123123", "email"=> "scout@scout_promotions.net"}}
    )
    
    silverton = SingleDayEvent.find_by_name('Silverton')
    assert_not_nil(silverton.promoter, 'Silverton promoter')
    candi_murray.reload
    assert_not_equal(candi_murray, silverton.promoter, "Silverton Promoter")
    assert_equal(old_name, candi_murray.name, "Candi name")
    assert_equal(old_email, candi_murray.email, "Candi email")
    assert_equal(old_phone, candi_murray.phone, "Candi phone")

    assert_equal(candi_murray.name, silverton.promoter.name, "Promoter email")
    assert_equal('scout@scout_promotions.net', silverton.promoter.email, "Promoter email")
    assert_equal('123123', silverton.promoter.phone, "Promoter phone")
  end
  
  def test_save_new_single_day_existing_promoter_no_name
    nate_hobson = promoters(:nate_hobson)
    old_name = nate_hobson.name
    old_email = nate_hobson.email
    old_phone = nate_hobson.phone

    @request.session[:user] = users(:candi)
    post(:create, 
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>"Silverton",
                  'promoter' => {"name" => '',  "phone"=> nate_hobson.phone, "email"=> nate_hobson.email}}
    )
    
    silverton = SingleDayEvent.find_by_name('Silverton')
    assert(!silverton.new_record?, "Silverton should be saved")
    assert_equal(nate_hobson, silverton.promoter, "Silverton Promoter")
    assert_equal(old_name, silverton.promoter.name, "Promoter name")
    assert_equal(old_email, silverton.promoter.email, "Promoter email")
    assert_equal(old_phone, silverton.promoter.phone, "Promoter phone")
  end
  
  # def test_save_new_multi_day_existing_promoter_different_info_overwrite
  #   candi_murray = promoters(:candi_murray)
  #   event_window.promoter_name.text = candi_murray.name
  #   new_email = "scout@scout_promotions.net"
  #   event_window.promoter_email.text = new_email
  #   new_phone = "123123"
  #   event_window.promoter_phone.text = new_phone
  #   FXMessageBox.answer = MBOX_CLICKED_YES
  #   event_window.save!
  #   
  #   @request.session[:user] = users(:candi)
  #   post(:create, 
  #        "commit"=>"Save", 
  #        'same_promoter' => 'true',
  #        "event"=>{"name"=>"Silverton",
  #                 'promoter' => {"name" => '',  "phone"=> nate_hobson.phone, "email"=> nate_hobson.email}}
  #   )
  #   
  #   assert(!event_window.event.new_record?, "Event should be saved")
  #   silverton_sr = MultiDayEvent.find_by_name('Silverton SR')
  #   assert_equal(candi_murray, silverton_sr.promoter, "Silverton Promoter")
  #   assert_equal(new_email, silverton_sr.promoter.email, "Promoter email")
  #   assert_equal(new_phone, silverton_sr.promoter.phone, "Promoter phone")
  # end
  # 
  # def test_save_new_multi_day_existing_promoter_different_info_do_not_overwrite
  #   candi_murray = promoters(:candi_murray)
  #   silverton_sr = RemoteMultiDayEvent.new(:discipline => "Road", :name => 'Silverton SR')
  #   event_window = EventWindow.new(@app, silverton_sr)
  #   event_window.promoter_name.text = candi_murray.name
  #   old_email = candi_murray.email
  #   old_phone = candi_murray.phone
  #   event_window.promoter_email.text = "scout@scout_promotions.net"
  #   event_window.promoter_phone.text = "123123"
  #   FXMessageBox.answer = MBOX_CLICKED_NO
  #   event_window.save!
  #   
  #   assert(!event_window.event.new_record?, "Event should be saved")
  #   silverton_sr = MultiDayEvent.find_by_name('Silverton SR')
  #   assert_equal(candi_murray, silverton_sr.promoter, "Silverton Promoter")
  #   assert_equal(old_email, silverton_sr.promoter.email, "Promoter email")
  #   assert_equal(old_phone, silverton_sr.promoter.phone, "Promoter phone")
  # end
  
  def test_save_single_day_existing_promoter_new_info
    candi_murray = promoters(:candi_murray)
    email = candi_murray.email
    phone = candi_murray.phone
    jack_frost = events(:jack_frost)

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => jack_frost.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>"Jack Frost",
                  'promoter' => {"name" => candi_murray.name,  "phone"=> '', "email"=> ''}}
    )
    
    jack_frost.reload
    assert_equal(candi_murray, jack_frost.promoter, "Jack Frost Promoter")
    assert_equal("", jack_frost.promoter.email, "Jack Frost promoter email should be blank")
    assert_equal("", jack_frost.promoter.phone, "Jack Frost promoter phone should be blank")
  end
  
  def test_save_single_day_no_promoter
    jack_frost = events(:jack_frost)

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => jack_frost.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>"Jack Frost",
                  'promoter' => {"name" => '',  "phone"=> '', "email"=> ''}}
    )
    
    jack_frost.reload
    assert_nil(jack_frost.promoter, "Jack Frost Promoter")
  end

  def test_save_single_day_existing_promoter_different_info_overwrite
    candi_murray = promoters(:candi_murray)
    jack_frost = events(:jack_frost)
    new_email = "scout@scout_promotions.net"
    new_phone = "123123"

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => jack_frost.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>"Silverton",
                  'promoter' => {"name" => candi_murray.name,  "phone"=> new_phone, "email"=> new_email}}
    )
    
    jack_frost.reload
    assert_equal(candi_murray, jack_frost.promoter, "Jack Frost Promoter")
    assert_equal(new_email, jack_frost.promoter.email, "Promoter email")
    assert_equal(new_phone, jack_frost.promoter.phone, "Promoter phone")
  end
  
  def test_save_single_day_existing_promoter_different_info_do_not_overwrite
    candi_murray = promoters(:candi_murray)
    jack_frost = events(:jack_frost)
    old_email = candi_murray.email
    old_phone = candi_murray.phone

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => jack_frost.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'false',
         "event"=>{"name"=>"Jack Frost",
                  'promoter' => {"name" => candi_murray.name,  "phone"=> "123123", "email"=> "scout@scout_promotions.net"}}
    )
    
    jack_frost.reload
    assert_equal(candi_murray, jack_frost.promoter, "Jack Frost Promoter")
    assert_equal(old_email, jack_frost.promoter.email, "Promoter email")
    assert_equal(old_phone, jack_frost.promoter.phone, "Promoter phone")
  end
  
  def test_save_single_day_existing_promoter_no_name
    nate_hobson = promoters(:nate_hobson)
    jack_frost = events(:jack_frost)
    old_email = nate_hobson.email
    old_phone = nate_hobson.phone

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => jack_frost.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'false',
         "event"=>{"name"=>"Jack Frost",
                  'promoter' => {"name" => '',  'phone' => nate_hobson.phone, "email"=> nate_hobson.email}}
    )
    
    assert_response(:success)
    assert_template('admin/events/show')
    assert_not_nil(assigns["event"], "Should assign event")
    assert_not_nil(flash[:warn], "Should have warning")

    jack_frost.reload
    assert_nil(jack_frost.promoter, "Jack Frost Promoter")
  end
  
  def test_save_single_day_existing_promoter_clear_info
    brad_ross = promoters(:brad_ross)
    pir_2 = events(:pir_2)

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => pir_2.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>pir_2.name,
                  'promoter' => {"name" => brad_ross.name,  'phone' => '', "email"=> ''}}
    )
    
    pir_2.reload
    assert_equal(brad_ross, pir_2.promoter, "PIR Promoter")
    assert(pir_2.promoter.email.blank?, "PIR promoter email should be blank")
    assert(pir_2.promoter.phone.blank?, "PIR promoter phone should be blank")
  end
  
  def test_save_single_day_existing_promoter_to_new
    pir_2 = events(:pir_2)
    name = "Jeff Willson"
    email = "backhill33@aol.com"
    phone = "(315) 655-2961"

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => pir_2.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'false',
         "event"=>{"name"=>pir_2.name,
                  'promoter' => {"name" => name,  'phone' => phone, "email"=> email}}
    )
    
    pir_2.reload
    assert_not_nil(pir_2.promoter, "PIR Promoter")
    assert_equal(name, pir_2.promoter.name, "PIR promoter name")
    assert_equal(email, pir_2.promoter.email, "PIR promoter email")
    assert_equal(phone, pir_2.promoter.phone, "PIR promoter phone")
  end
  
  def test_save_single_day_existing_promoter
    pir_2 = events(:pir_2)
    candi_murray = promoters(:candi_murray)

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => pir_2.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>pir_2.name,
                  'promoter' => {"name" => candi_murray.name,  'phone' => candi_murray.phone, "email"=> candi_murray.email}}
    )
    
    pir_2.reload
    assert_equal(candi_murray, pir_2.promoter, "PIR Promoter")
    assert_equal(candi_murray.name, pir_2.promoter.name, "PIR promoter name")
    assert_equal(candi_murray.email, pir_2.promoter.email, "PIR promoter email")
    assert_equal(candi_murray.phone, pir_2.promoter.phone, "PIR promoter phone")
  end
  
  def test_save_single_day_existing_promoter_with_overwrite
    pir_2 = events(:pir_2)
    candi_murray = promoters(:candi_murray)
    email = "backhill33@aol.com"
    phone = "(315) 655-2961"

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => pir_2.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>pir_2.name,
                  'promoter' => {"name" => candi_murray.name,  'phone' => phone, "email"=> email}}
    )
    
    pir_2.reload
    assert_equal(candi_murray, pir_2.promoter, "PIR Promoter")
    assert_equal(candi_murray.name, pir_2.promoter.name, "PIR promoter name")
    assert_equal(email, pir_2.promoter.email, "PIR promoter email")
    assert_equal(phone, pir_2.promoter.phone, "PIR promoter phone")
  end

  def test_save_single_day_existing_promoter_to_none
    pir_2 = events(:pir_2)

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => pir_2.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=>pir_2.name,
                  'promoter' => {"name" => '',  'phone' => '', "email"=> ''}}
    )
    
    pir_2.reload
    assert_nil(pir_2.promoter, "PIR Promoter")
  end
  
  def test_save_single_day_existing_no_name_promoter_to_existing
    brad_ross = promoters(:brad_ross)
    tabor_cr = events(:tabor_cr)

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => tabor_cr.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=> tabor_cr.name,
                  'promoter' => {"name" => brad_ross.name,  'phone' => '', "email"=> ''}}
    )
    
    tabor_cr.reload
    assert_equal(brad_ross, tabor_cr.promoter, "Tabor Promoter")
    assert(tabor_cr.promoter.email.blank?, "Tabor promoter email should be blank")
    assert(tabor_cr.promoter.phone.blank?, "Tabor promoter phone should be blank")
  end
  
  def test_save_single_day_existing_no_name_promoter_to_new
    tabor_cr = events(:tabor_cr)
    name = "Jeff Willson"
    email = "backhill33@aol.com"
    phone = "(315) 655-2961"

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => tabor_cr.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=> tabor_cr.name,
                  'promoter' => {"name" => name,  'phone' => phone, "email"=> email}}
    )
    
    tabor_cr.reload
    assert_not_nil(tabor_cr.promoter, "Tabor Promoter")
    assert_equal(name, tabor_cr.promoter.name, "Tabor promoter name")
    assert_equal(email, tabor_cr.promoter.email, "Tabor promoter email")
    assert_equal(phone, tabor_cr.promoter.phone, "Tabor promoter phone")
  end
  
  def test_save_single_day_existing_no_name_promoter
    tabor_cr = events(:tabor_cr)
    candi_murray = promoters(:candi_murray)

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => tabor_cr.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=> tabor_cr.name,
                  'promoter' => {"name" => candi_murray.name,  'phone' => candi_murray.phone, "email"=> candi_murray.email}}
    )
    
    tabor_cr.reload
    assert_equal(candi_murray, tabor_cr.promoter, "Tabor Promoter")
    assert_equal(candi_murray.name, tabor_cr.promoter.name, "Tabor promoter name")
    assert_equal(candi_murray.email, tabor_cr.promoter.email, "Tabor promoter email")
    assert_equal(candi_murray.phone, tabor_cr.promoter.phone, "Tabor promoter phone")
  end
  
  def test_save_single_day_existing_no_name_promoter_with_overwrite
    tabor_cr = events(:tabor_cr)
    candi_murray = promoters(:candi_murray)
    name = candi_murray.name
    email = "backhill33@aol.com"
    phone = "(315) 655-2961"

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => tabor_cr.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=> tabor_cr.name,
                  'promoter' => {"name" => name,  'phone' => phone, "email"=> email}}
    )
    
    tabor_cr.reload
    assert_equal(candi_murray, tabor_cr.promoter, "Tabor Promoter")
    assert_equal(name, tabor_cr.promoter.name, "Tabor promoter name")
    assert_equal(email, tabor_cr.promoter.email, "Tabor promoter email")
    assert_equal(phone, tabor_cr.promoter.phone, "Tabor promoter phone")
  end

  def test_save_single_day_existing_no_name_promoter_to_none
    tabor_cr = events(:tabor_cr)

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => tabor_cr.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'true',
         "event"=>{"name"=> tabor_cr.name,
                  'promoter' => {"name" => '',  'phone' => '', "email"=> ''}}
    )
    
    tabor_cr.reload
    assert_nil(tabor_cr.promoter, "Tabor Promoter")
  end

  def test_save_single_day_existing_no_name_promoter_to_none_not_same
    tabor_cr = events(:tabor_cr)

    @request.session[:user] = users(:candi)
    post(:update,
         'id' => tabor_cr.to_param,
         "commit"=>"Save", 
         'same_promoter' => 'false',
         "event"=>{"name"=> tabor_cr.name,
                  'promoter' => {"name" => '',  'phone' => '', "email"=> ''}}
    )
    
    tabor_cr.reload
    assert_nil(tabor_cr.promoter, "Tabor Promoter")
  end

end
