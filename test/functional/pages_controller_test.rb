require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "show page" do
    get :show, :path => ["plain"]
  end

  test "render root page" do
    Page.create!(:body => "<h1>Welcome</h1>")
    get :show, :path => [""]
    assert_select("h1", :text => "Welcome")
  end
    
  test "render child page" do
    root = Page.create!(:body => "<h1>Welcome</h1>")
    root.children.create!(:body => "<h2>Child</h2>", :title => "Child")

    get :show, :path => ["child"]
    assert_select("h2", :text => "Child")
  end
  
  test "render child's child" do
    root = Page.create!(:body => "<h1>Welcome</h1>")
    child = root.children.create!(:body => "<h2>Child</h2>", :title => "Child")
    child_child = child.children.create!(:body => "<h3>Nested</h3>", :title => "Nested")

    get :show, :path => ["child", "nested"]
    assert_select("h3", :text => "Nested")
  end
  
  def test_index
    root = Page.create!(:body => "<h1>Welcome</h1>")
    child = root.children.create!(:body => "<h2>Child</h2>", :title => "Child")
    child_child = child.children.create!(:body => "<h3>Nested</h3>", :title => "Nested")

    get :show, :path => ["child", "index"]
    assert_select("h2", :text => "Child")
  end

  test "render 404 correctly for missing page" do
    assert_raise(ActiveRecord::RecordNotFound) { get(:show, :path => ["not_a_page"]) }
    assert_response(:success)
  end
  
  test "render 404 correctly for missing children" do
    assert_raise(ActiveRecord::RecordNotFound) { get(:show, :path => ["parent", "child", "missing"]) }
    assert_response(:success)
  end
  
  # From file to start, but DB later
  test "render page with correct layout" do
    get :show, :path => ["plain"]
    assert_layout("application")
  end
  
  test "evaluate ERb" do
    Page.create!(:body => "<h1><%= \"foo\".reverse %></h1>")
    get :show, :path => [""]
    assert_select("h1", :text => "oof")
  end
  
  test "use view helpers" do
    Page.create!(:body => "<h1><%= number_to_currency(18.919, :precision => 2) %></h1>")
    get :show, :path => [""]
    assert_select("h1", :text => "$18.92")
  end
  
  test "use path-dependent view helpers" do
    root = Page.create!(:body => "<h1>Welcome</h1>")
    root.children.create!(:body => "<h1><%= link_to(\"Categories\", categories_path) %></h1>", :title => "Sitemap")
    get :show, :path => ["sitemap"]
    assert_select("a[href='/categories']", :text => "Categories")
  end
  
  test "call partials" do
    Page.create!(:body => "<h1>Mailing Lists</h1>\n<%= render :partial => 'shared/flash_messages' %>", :title => "lists")
    get :show, :path => ["lists"]
    assert_select("p.flash_message")
  end
  
  test "call partials with concise syntax" do
    Page.create!(:body => "<h1>Mailing Lists</h1>\n<%= render 'shared/flash_messages' %>", :title => "lists")
    get :show, :path => ["lists"]
    assert_select("p.flash_message")
  end
end
