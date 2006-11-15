require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/promoters_controller'

# Re-raise errors caught by the controller.
class Admin::PromotersController; def rescue_action(e) raise e end; end

class Admin::PromotersControllerTest < Test::Unit::TestCase
  def setup
    @controller = Admin::PromotersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:candi)
  end
  
  def test_index
    path = {:controller => "admin/promoters", :action => 'index'}
    assert_routing("/admin/promoters", path)
    assert_recognizes(path, "/admin/promoters/")
    assert_recognizes(path, "/admin/promoters/index")

    get(:index)
    assert_equal(3, assigns['promoters'].size, "Should assign all promoters to 'promoters'")
  end
  
  def test_show
    path = {:controller => "admin/promoters", :action => 'show', :id => '1'}
    assert_routing("/admin/promoters/1", path)
    
    get(:show, :id => '1')
    assert_equal(promoters(:brad_ross), assigns['promoter'], "Should assign 'promoter'")
    assert_nil(assigns['event'], "Should not assign 'event'")
  end

  def test_show_with_event
    kings_valley = events(:kings_valley)
    path = {:controller => "admin/promoters", :action => 'show', :id => '1', :event_id => kings_valley.to_param.to_s}
    assert_recognizes(path, "/admin/promoters/1", :event_id => kings_valley.to_param.to_s)
    
    get(:show, :id => '1', :event_id => kings_valley.to_param.to_s)
    assert_equal(promoters(:brad_ross), assigns['promoter'], "Should assign 'promoter'")
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
  end
  
  def test_new
    path = {:controller => "admin/promoters", :action => 'new'}
    assert_routing("/admin/promoters/new", path)
    
    get(:new)
    assert_not_nil(assigns['promoter'], "Should assign 'promoter'")
    assert(assigns['promoter'].new_record?, 'Promoter should be new record')
  end

  def test_new_with_event
    kings_valley = events(:kings_valley)
    path = {:controller => "admin/promoters", :action => 'new', :event_id => kings_valley.to_param.to_s}
    assert_recognizes(path, "/admin/promoters/new", :event_id => kings_valley.to_param.to_s)
    
    get(:new, :event_id => kings_valley.to_param.to_s)
    assert_not_nil(assigns['promoter'], "Should assign 'promoter'")
    assert(assigns['promoter'].new_record?, 'Promoter should be new record')
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
  end
  
  def test_create
  end
  
  def test_update
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
  
  # def test_save_new_single_day_existing_promoter_different_info_do_not_overwrite
  #   candi_murray = promoters(:candi_murray)
  #   old_name = candi_murray.name
  #   old_email = candi_murray.email
  #   old_phone = candi_murray.phone
  # 
  #   @request.session[:user] = users(:candi)
  #   post(:create, 
  #        "commit"=>"Save", 
  #        'same_promoter' => 'false',
  #        "event"=>{"name"=>"Silverton",
  #                 'promoter' => {"name" => candi_murray.name,  "phone"=> "123123", "email"=> "scout@scout_promotions.net"}}
  #   )
  #   
  #   silverton = SingleDayEvent.find_by_name('Silverton')
  #   assert_not_nil(silverton.promoter, 'Silverton promoter')
  #   candi_murray.reload
  #   assert_not_equal(candi_murray, silverton.promoter, "Silverton Promoter")
  #   assert_equal(old_name, candi_murray.name, "Candi name")
  #   assert_equal(old_email, candi_murray.email, "Candi email")
  #   assert_equal(old_phone, candi_murray.phone, "Candi phone")
  # 
  #   assert_equal(candi_murray.name, silverton.promoter.name, "Promoter email")
  #   assert_equal('scout@scout_promotions.net', silverton.promoter.email, "Promoter email")
  #   assert_equal('123123', silverton.promoter.phone, "Promoter phone")
  # end
  
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
