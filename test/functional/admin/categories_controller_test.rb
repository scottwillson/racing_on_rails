require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/categories_controller'

# Re-raise errors caught by the controller.
class Admin::CategoriesController; def rescue_action(e) raise e end; end

class Admin::CategoriesControllerTest < Test::Unit::TestCase

  def setup
    @controller = Admin::CategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
    @request.session[:user] = users(:candi)
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
  
  def test_index_with_id
    senior_women = categories(:senior_women)
    opts = {:controller => "admin/categories", :action => "index", :id => senior_women.id.to_s}
    assert_routing("/admin/categories/#{senior_women.id}", opts)
    get(:index, :id => senior_women.id)
    assert_response(:success)
    assert_template("admin/categories/index")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(senior_women, assigns["category"], 'category')
    assert_not_nil(assigns["unknowns"], "Should assign unknowns")
  end
  
  def test_not_logged_in
    @request.session[:user] = nil
    get(:index)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/admin/account', :action => 'login')
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_not_logged_in_edit
    @request.session[:user] = nil
    senior_women = categories(:senior_women)
    get(:edit_name, :id => senior_women.to_param)
    assert_response(:redirect)
    assert_redirected_to(:controller => '/admin/account', :action => 'login')
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_edit_name
    senior_women = categories(:senior_women)
    get(:edit_name, :id => senior_women.to_param)
    assert_response(:success)
    assert_template("admin/categories/_edit")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(senior_women, assigns['category'], 'category')
  end

  def test_blank_name
    senior_women = categories(:senior_women)
    post(:update, :id => senior_women.to_param, :name => '')
    assert_response(:success)
    assert_template("admin/categories/_edit")
    assert_not_nil(assigns["category"], "Should assign category")
    assert(!assigns["category"].errors.empty?, 'Attempt to assign blank name should add error')
    assert_equal(senior_women, assigns['category'], 'category')
    senior_women.reload
    assert_equal('Senior Women', senior_women.name, 'category name after cancel')
  end

  def test_cancel
    senior_women = categories(:senior_women)
    original_name = senior_women.name
    get(:cancel, :id => senior_women.to_param, :name => senior_women.name)
    assert_response(:success)
    assert_template("/admin/_attribute")
    senior_women.reload
    assert_equal(original_name, senior_women.name, 'Category name after cancel')
  end

  def test_update
    senior_women = categories(:senior_women)
    post(:update, :id => senior_women.to_param, :name => 'Senior Chiquas')
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(senior_women, assigns['category'], 'Category')
    senior_women.reload
    assert_equal('Senior Chiquas', senior_women.name, 'Category name after update')
  end
  
  def test_update_same_name
    senior_women = categories(:senior_women)
    post(:update, :id => senior_women.to_param, :name => 'Senior Women')
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(senior_women, assigns['category'], 'Category')
    senior_women.reload
    assert_equal('Senior Women', senior_women.name, 'Category name after update')
  end
  
  def test_update_same_name_different_case
    senior_women = categories(:senior_women)
    post(:update, :id => senior_women.to_param, :name => 'senior women')
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(senior_women, assigns['category'], 'Category')
    senior_women.reload
    assert_equal('senior women', senior_women.name, 'Category name after update')
  end
  
  def test_update_to_existing_name
    senior_women = categories(:senior_women)
    post(:update, :id => senior_women.to_param, :name => 'Senior Men')
    assert_response(:success)
    assert(!assigns["category"].errors.empty?, 'Attempt to assign blank name should add error')
    assert_equal(senior_women, assigns['category'], 'category')
    senior_women.reload
    assert_equal('Senior Women', senior_women.name, 'category name after cancel')
  end
  
  def test_destroy
    unicycle = Category.create(:name => 'Unicycle')
    post(:destroy, :id => unicycle.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'Unicycle should have been destroyed') { Category.find(unicycle.id) }
  end

  def test_new_inline
    opts = {:controller => "admin/categories", :action => "new_inline"}
    assert_routing("/admin/categories/new_inline", opts)
  
    get(:new_inline)
    assert_response(:success)
    assert_template("/admin/_new_inline")
    assert_not_nil(assigns["record"], "Should assign category as 'record'")
    assert_not_nil(assigns["icon"], "Should assign 'icon'")
  end
  
  def test_create
    opts = {:controller => "admin/categories", :action => "create"}
    assert_routing("/admin/categories/create", opts)

    assert_nil(Category.find_by_name('Senior Chiquas'), 'Senior Chiquas category should not exist')
    post(:create, :name => 'Senior Chiquas')
    assert_response(:success)
    assert_not_nil(Category.find_by_name('Senior Chiquas'), 'Senior Chiquas category should exist')
  end
end