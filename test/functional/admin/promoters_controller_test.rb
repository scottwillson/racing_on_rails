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
    assert_template("admin/promoters/index")
  end
  
  def test_show
    path = {:controller => "admin/promoters", :action => 'show', :id => '1'}
    assert_routing("/admin/promoters/1", path)
    
    get(:show, :id => '1')
    assert_equal(promoters(:brad_ross), assigns['promoter'], "Should assign 'promoter'")
    assert_nil(assigns['event'], "Should not assign 'event'")
    assert_template("admin/promoters/show")
  end

  def test_show_with_event
    kings_valley = events(:kings_valley)
    path = {:controller => "admin/promoters", :action => 'show', :id => '1', :event_id => kings_valley.to_param.to_s}
    assert_recognizes(path, "/admin/promoters/1", :event_id => kings_valley.to_param.to_s)
    
    get(:show, :id => '1', :event_id => kings_valley.to_param.to_s)
    assert_equal(promoters(:brad_ross), assigns['promoter'], "Should assign 'promoter'")
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/promoters/show")
  end
  
  def test_new
    path = {:controller => "admin/promoters", :action => 'new'}
    assert_routing("/admin/promoters/new", path)
    
    get(:new)
    assert_not_nil(assigns['promoter'], "Should assign 'promoter'")
    assert(assigns['promoter'].new_record?, 'Promoter should be new record')
    assert_template("admin/promoters/show")
  end

  def test_new_with_event
    kings_valley = events(:kings_valley)
    path = {:controller => "admin/promoters", :action => 'new', :event_id => kings_valley.to_param.to_s}
    assert_recognizes(path, "/admin/promoters/new", :event_id => kings_valley.to_param.to_s)
    
    get(:new, :event_id => kings_valley.to_param.to_s)
    assert_not_nil(assigns['promoter'], "Should assign 'promoter'")
    assert(assigns['promoter'].new_record?, 'Promoter should be new record')
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/promoters/show")
  end
  
  def test_create
    path = {:controller => "admin/promoters", :action => 'update'}
    assert_routing("/admin/promoters/update", path)
    
    assert_nil(Promoter.find_by_name("Fred Whatley"), 'Fred Whatley should not be in database')
    post(:update, "promoter" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter = Promoter.find_by_name("Fred Whatley")
    assert_not_nil(promoter, 'New promoter should be database')
    assert_equal('Fred Whatley', promoter.name, 'new promoter name')
    assert_equal('(510) 410-2201', promoter.phone, 'new promoter name')
    assert_equal('fred@whatley.net', promoter.email, 'new promoter email')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => promoter.to_param)
  end
  
  def test_update
    promoter = promoters(:brad_ross)
    
    assert_not_equal('Fred Whatley', promoter.name, 'existing promoter name')
    assert_not_equal('(510) 410-2201', promoter.phone, 'existing promoter name')
    assert_not_equal('fred@whatley.net', promoter.email, 'existing promoter email')

    post(:update, :id => promoter.id, 
      "promoter" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter.reload
    assert_equal('Fred Whatley', promoter.name, 'new promoter name')
    assert_equal('(510) 410-2201', promoter.phone, 'new promoter phone')
    assert_equal('fred@whatley.net', promoter.email, 'new promoter email')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => promoter.to_param)
  end

  def test_save_new_single_day_existing_promoter_different_info_overwrite
    candi_murray = promoters(:candi_murray)
    new_email = "scout@scout_promotions.net"
    new_phone = "123123"

    post(:update, :id => candi_murray.id, 
      "promoter" => {"name" => candi_murray.name, "phone" => new_phone, "email" => new_email}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    candi_murray.reload
    assert_equal(candi_murray.name, candi_murray.name, 'promoter old name')
    assert_equal(new_phone, candi_murray.phone, 'promoter new phone')
    assert_equal(new_email, candi_murray.email, 'promoter new email')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => candi_murray.to_param)
  end
  
  def test_save_new_single_day_existing_promoter_no_name
    nate_hobson = promoters(:nate_hobson)
    old_name = nate_hobson.name
    old_email = nate_hobson.email
    old_phone = nate_hobson.phone

    post(:update, :id => nate_hobson.id, 
      "promoter" => {"name" => '', "phone" => old_phone, "email" => old_email}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter.reload
    assert_equal('', promoter.name, 'promoter name')
    assert_equal(old_phone, promoter.phone, 'promoter old phone')
    assert_equal(old_email, promoter.email, 'promoter old email')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :show, :id => promoter.to_param)
  end
  
  def test_update_blank_info
    candi_murray = promoters(:candi_murray)

    post(:update, :id => candi_murray.id, 
      "promoter" => {"name" => '', "phone" => '', "email" => ''}, "commit" => "Save")
    
    assert(!assigns['promoter'].errors.empty?, 'promoter should have errors')
    
    candi_murray.reload
    assert(!candi_murray.name.blank?, 'promoter name')
    assert(!candi_murray.email.blank?, 'promoter email')
    assert(!candi_murray.phone.blank?, 'promoter phone')
    
    assert_response(:success)
    assert_template("admin/promoters/show")
  end

  def test_save_single_day_existing_promoter_different_info_do_not_overwrite
    candi_murray = promoters(:candi_murray)
    candi_old_email = candi_murray.email
    candi_old_phone = candi_murray.phone

    nate_hobson = promoters(:nate_hobson)
    nate_old_name = nate_hobson.name
    nate_old_email = nate_hobson.email
    nate_old_phone = nate_hobson.phone

    post(:update,
         'id' => candi_murray.to_param,
         "commit"=>"Save", 
         'promoter' => {"name" => nate_hobson.name,  "phone"=> candi_murray.phone, "email"=> candi_murray.email}
    )
    
    assert(!assigns['promoter'].errors.empty?, 'promoter should have errors')
    
    candi_murray.reload
    assert_equal(candi_old_email, candi_murray.email, 'Candi email')
    assert_equal(candi_old_phone, candi_murray.phone, 'Candi phone')
    
    nate_hobson.reload
    assert_equal(nate_old_name, nate_hobson.name, 'nate_hobson name')
    assert_equal(nate_old_email, nate_hobson.email, 'nate_hobson email')
    assert_equal(nate_old_phone, nate_hobson.phone, 'nate_hobson phone')
    
    assert_response(:success)
    assert_template("admin/promoters/show")
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
  
  def test_remember_event_id_on_update
    flunk
  end

end
