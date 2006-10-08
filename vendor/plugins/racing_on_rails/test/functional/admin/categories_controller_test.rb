require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/categories_controller'

# Re-raise errors caught by the controller.
class Admin::CategoriesController; def rescue_action(e) raise e end; end

class Admin::CategoriesControllerTest < Test::Unit::TestCase

  fixtures :teams, :aliases, :users, :promoters, :categories

  def setup
    @controller = Admin::CategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.host = "localhost"
  end

  def test_index
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/categories", :action => "index"}
    assert_routing("/admin/categories", opts)
    get(:index)
    assert_response(:success)
    assert_template("admin/categories/index")
    assert_not_nil(assigns["categories"], "Should assign categories")
  end
  
  def test_not_logged_in
    get(:index)
    assert_response(:redirect)
    assert_redirect_url "http://localhost/admin/account/login"
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_not_logged_in_edit
    senior_women_bar = categories(:senior_women_bar)
    get(:edit_name, :id => senior_women_bar.to_param)
    assert_response(:redirect)
    assert_redirect_url "http://localhost/admin/account/login"
    assert_nil(@request.session["user"], "No user in session")
  end

  def test_edit_name
    @request.session[:user] = users(:candi)
    senior_women_bar = categories(:senior_women_bar)
    get(:edit_name, :id => senior_women_bar.to_param)
    assert_response(:success)
    assert_template("admin/categories/_edit")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(senior_women_bar, assigns['category'], 'category')
  end

  def test_blank_name
    @request.session[:user] = users(:candi)
    senior_women_bar = categories(:senior_women_bar)
    post(:update, :id => senior_women_bar.to_param, :name => '')
    assert_response(:success)
    assert_template("admin/categories/_edit")
    assert_not_nil(assigns["category"], "Should assign category")
    assert(!assigns["category"].errors.empty?, 'Attempt to assign blank name should add error')
    assert_equal(senior_women_bar, assigns['category'], 'category')
    senior_women_bar.reload
    assert_equal('Senior Women', senior_women_bar.name, 'category name after cancel')
  end

  def test_cancel
    @request.session[:user] = users(:candi)
    senior_women_bar = categories(:senior_women_bar)
    original_name = senior_women_bar.name
    get(:cancel, :id => senior_women_bar.to_param, :name => senior_women_bar.name)
    assert_response(:success)
    assert_template("/admin/_attribute")
    senior_women_bar.reload
    assert_equal(original_name, senior_women_bar.name, 'Category name after cancel')
  end

  def test_update
    @request.session[:user] = users(:candi)
    senior_women_bar = categories(:senior_women_bar)
    post(:update, :id => senior_women_bar.to_param, :name => 'Senior Chiquas')
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(senior_women_bar, assigns['category'], 'Category')
    senior_women_bar.reload
    assert_equal('Senior Chiquas', senior_women_bar.name, 'Category name after update')
  end
  
  def test_update_same_name
    @request.session[:user] = users(:candi)
    senior_women_bar = categories(:senior_women_bar)
    post(:update, :id => senior_women_bar.to_param, :name => 'Senior Women')
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(senior_women_bar, assigns['category'], 'Category')
    senior_women_bar.reload
    assert_equal('Senior Women', senior_women_bar.name, 'Category name after update')
  end
  
  def test_update_same_name_different_case
    @request.session[:user] = users(:candi)
    senior_women_bar = categories(:senior_women_bar)
    post(:update, :id => senior_women_bar.to_param, :name => 'senior women')
    assert_response(:success)
    assert_template("/admin/_attribute")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(senior_women_bar, assigns['category'], 'Category')
    senior_women_bar.reload
    assert_equal('senior women', senior_women_bar.name, 'Category name after update')
  end
  
  def test_update_to_existing_name
    @request.session[:user] = users(:candi)
    senior_women_bar = categories(:senior_women_bar)
    post(:update, :id => senior_women_bar.to_param, :name => 'Senior Men')
    assert_response(:success)
    assert(!assigns["category"].errors.empty?, 'Attempt to assign blank name should add error')
    assert_equal(senior_women_bar, assigns['category'], 'category')
    senior_women_bar.reload
    assert_equal('Senior Women', senior_women_bar.name, 'category name after cancel')
  end
  
  def test_destroy
    @request.session[:user] = users(:candi)
    unicycle = Category.create(:name => 'Unicycle')
    post(:destroy, :id => unicycle.id, :commit => 'Delete')
    assert_response(:success)
    assert_raise(ActiveRecord::RecordNotFound, 'Unicycle should have been destroyed') { Category.find(unicycle.id) }
  end

  def test_new_inline
    @request.session[:user] = users(:candi)
    opts = {:controller => "admin/categories", :action => "new_inline"}
    assert_routing("/admin/categories/new_inline", opts)
  
    get(:new_inline)
    assert_response(:success)
    assert_template("/admin/_new_inline")
    assert_not_nil(assigns["record"], "Should assign category as 'record'")
    assert_not_nil(assigns["icon"], "Should assign 'icon'")
  end

  def test_edit_bar_category
    @request.session[:user] = users(:candi)
    senior_women_bar = categories(:senior_women_bar)
    get(:edit_bar_category, :id => senior_women_bar.to_param)
    assert_response(:success)
    assert_template("admin/categories/_edit_bar_category")
  end

  def test_update_bar_category
    @request.session[:user] = users(:candi)
    cat_3 = categories(:cat_3)
    senior_women_bar = categories(:senior_women_bar)
    assert(cat_3.bar_category != senior_women_bar, 'Cat 3 BAR category should not be Senior Women')
    
    post(:update_bar_category, :category => {:id => cat_3.to_param}, :bar_category_id => senior_women_bar.id)
    
    assert_response(:success)
    assert_template("admin/categories/_bar_category")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(cat_3, assigns['category'], 'Category')
    cat_3.reload
    assert_equal(senior_women_bar, cat_3.bar_category, 'Cat 3 BAR category should be Senior Women')
  end
  
  def test_update_to_no_bar_category
    @request.session[:user] = users(:candi)
    cat_3 = categories(:cat_3)
    assert_not_nil(cat_3.bar_category, 'Cat 3 BAR category should not be nil')
    
    post(:update_bar_category, :category => {:id => cat_3.to_param}, :bar_category_id => "")
    
    assert_response(:success)
    assert_template("admin/categories/_bar_category")
    assert_not_nil(assigns["category"], "Should assign category")
    assert_equal(cat_3, assigns['category'], 'Category')
    cat_3.reload
    assert_nil(cat_3.bar_category, 'Cat 3 BAR category should be nil')
  end
  
  def test_insert_at
    @request.session[:user] = users(:candi)
    sr_p_1_2 = categories(:sr_p_1_2)
    sr_women = categories(:sr_women)
    assert(sr_p_1_2.position < sr_women.position, 'Pro 1/2 should be lower position than senior women')
  
    opts = {:controller => "admin/categories", :action => "insert_at"}
    assert_routing("/admin/categories/insert_at", opts)
  
    get(:insert_at, :id => "category_#{sr_women.id}", :target_id => sr_p_1_2.id)
    assert_response(:success)
    assert_template("admin/categories/_category")

    sr_p_1_2.reload
    sr_women.reload
    assert(sr_p_1_2.position > sr_women.position, 'Pro 1/2 should be higher position than senior women')
  end
end