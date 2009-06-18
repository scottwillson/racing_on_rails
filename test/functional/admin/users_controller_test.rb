require "test_helper"

# :stopdoc:
class Admin::UsersControllerTest < ActionController::TestCase
  setup :create_administrator_session

  def test_index
    path = {:controller => "admin/users", :action => 'index'}
    assert_routing("/admin/users", path)
    assert_recognizes(path, "/admin/users/")

    get(:index)
    assert_equal(4, assigns['users'].size, "Should assign all promoters to 'users'")
    assert_template("admin/users/index")
  end
  
  def test_edit
    get(:edit, :id => users(:promoter).to_param)
    assert_equal(users(:promoter), assigns['user'], "Should assign 'user'")
    assert_nil(assigns['event'], "Should not assign 'event'")
    assert_template("admin/users/edit")
  end

  def test_edit_with_event
    kings_valley = events(:kings_valley)
    get(:edit, :id => users(:promoter).to_param, :event_id => kings_valley.to_param.to_s)
    assert_equal(users(:promoter), assigns['user'], "Should assign 'user'")
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/users/edit")
  end
  
  def test_new
    path = {:controller => "admin/users", :action => 'new'}
    assert_routing("/admin/users/new", path)
    
    get(:new)
    assert_not_nil(assigns['user'], "Should assign 'user'")
    assert(assigns['user'].new_record?, 'Promoter should be new record')
    assert_template("admin/users/edit")
  end

  def test_new_with_event
    kings_valley = events(:kings_valley)
    get(:new, :event_id => kings_valley.to_param)
    assert_not_nil(assigns['user'], "Should assign 'user'")
    assert(assigns['user'].new_record?, 'Promoter should be new record')
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/users/edit")
  end
  
  def test_create
    assert_nil(User.find_by_name("Fred Whatley"), 'Fred Whatley should not be in database')
    post(:create, "user" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter = User.find_by_name("Fred Whatley")
    assert_not_nil(promoter, 'New promoter should be database')
    assert_equal('Fred Whatley', promoter.name, 'new promoter name')
    assert_equal('(510) 410-2201', promoter.phone, 'new promoter name')
    assert_equal('fred@whatley.net', promoter.email, 'new promoter email')
    
    assert_response(:redirect)
    assert_redirected_to(edit_admin_user_path(promoter))
  end
  
  def test_update
    promoter = users(:promoter)
    
    assert_not_equal('Fred Whatley', promoter.name, 'existing promoter name')
    assert_not_equal('(510) 410-2201', promoter.phone, 'existing promoter name')
    assert_not_equal('fred@whatley.net', promoter.email, 'existing promoter email')

    put(:update, :id => promoter.id, 
      "user" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter.reload
    assert_equal('Fred Whatley', promoter.name, 'new promoter name')
    assert_equal('(510) 410-2201', promoter.phone, 'new promoter phone')
    assert_equal('fred@whatley.net', promoter.email, 'new promoter email')
    
    assert_response(:redirect)
    assert_redirected_to(edit_admin_user_path(promoter))
  end

  def test_save_new_single_day_existing_promoter_different_info_overwrite
    candi_murray = users(:administrator)
    new_email = "scout@scout-promotions.net"
    new_phone = "123123"

    put(:update, :id => candi_murray.id, 
      "user" => {"name" => candi_murray.name, "phone" => new_phone, "email" => new_email}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    assert_not_nil(assigns["user"], "@user")
    assert(assigns["user"].errors.empty?, assigns["user"].errors.full_messages)

    assert_response(:redirect)
    assert_redirected_to(edit_admin_user_path(candi_murray))
    
    candi_murray.reload
    assert_equal(candi_murray.name, candi_murray.name, 'promoter old name')
    assert_equal(new_phone, candi_murray.phone, 'promoter new phone')
    assert_equal(new_email, candi_murray.email, 'promoter new email')
  end
  
  def test_save_new_single_day_existing_promoter_no_name
    nate_hobson = users(:nate_hobson)
    old_name = nate_hobson.name
    old_email = nate_hobson.email
    old_phone = nate_hobson.phone

    put(:update, :id => nate_hobson.id, 
      "user" => {"name" => '', "phone" => old_phone, "email" => old_email}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    nate_hobson.reload
    assert_equal('', nate_hobson.name, 'promoter name')
    assert_equal(old_phone, nate_hobson.phone, 'promoter old phone')
    assert_equal(old_email, nate_hobson.email, 'promoter old email')
    
    assert_response(:redirect)
    assert_redirected_to(edit_admin_user_path(nate_hobson))
  end
  
  def test_remember_event_id_on_update
    promoter = users(:promoter)

    put(:update, :id => promoter.id, 
      "user" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, 
      "commit" => "Save",
      "event_id" => events(:jack_frost).id)
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter.reload
    
    assert_response(:redirect)
    assert_redirected_to(edit_admin_event_user_path(promoter, events(:jack_frost)))
  end
  
  def test_remember_event_id_on_create
    post(:create, "user" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, 
    "commit" => "Save",
    "event_id" => events(:jack_frost).id)
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter = User.find_by_name('Fred Whatley')
    assert_response(:redirect)
    assert_redirected_to(edit_admin_event_user_path(promoter, events(:jack_frost)))
  end
end
