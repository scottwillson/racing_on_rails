require File.dirname(__FILE__) + '/../../test_helper'

class Admin::CategoriesControllerTest < ActionController::TestCase

  def setup
    @request.session[:user] = users(:administrator)
  end

  def test_index
    opts = {:controller => "admin/categories", :action => "index"}
    assert_routing("/admin/categories", opts)
    get(:index)
    assert_response(:success)
    assert_template("admin/categories/index")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_not_nil(assigns["unknowns"], "Should assign unknowns")
  end
  
  def test_not_logged_in
    @request.session[:user] = nil
    get(:index)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/admin/account', :action => 'login')
    assert_nil(@request.session["user"], "No user in session")
  end  
end