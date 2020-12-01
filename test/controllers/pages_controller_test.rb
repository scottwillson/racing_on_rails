# frozen_string_literal: true

require File.expand_path("../test_helper", __dir__)

ActionController::Base.prepend_view_path "test/fixtures/views"

# :stopdoc:
class PagesControllerTest < ActionController::TestCase
  setup :create_page

  test "show page" do
    get :show, params: { path: "plain" }
  end

  test "render child page" do
    root = Page.create!(body: "<h1>Welcome</h1>")
    root.children.create!(body: "<h2>Child</h2>", title: "Child")

    get :show, params: { path: "child" }
    assert_select("h2", text: "Child")
  end

  test "render child's child" do
    root = Page.create!(body: "<h1>Welcome</h1>")
    child = root.children.create!(body: "<h2>Child</h2>", title: "Child")
    child.children.create!(body: "<h3>Nested</h3>", title: "Nested")

    get :show, params: { path: "child/nested" }
    assert_select("h3", text: "Nested")
  end

  test "index" do
    root = Page.create!(body: "<h1>Welcome</h1>")
    child = root.children.create!(body: "<h2>Child</h2>", title: "Child")
    child.children.create!(body: "<h3>Nested</h3>", title: "Nested")

    get :show, params: { path: "child/index" }
    assert_select("h2", text: "Child")
  end

  test "render 404 correctly for missing page" do
    assert_raise(ActiveRecord::RecordNotFound) { get(:show, params: { path: "not_a_page" }) }
    assert_response(:success)
  end

  test "render 404 correctly for missing children" do
    assert_raise(ActiveRecord::RecordNotFound) { get(:show, params: { path: "parent/child/missing" }) }
    assert_response(:success)
  end

  # From file to start, but DB later
  test "render page with correct layout" do
    get :show, params: { path: "plain" }
    assert_template layout: "application"
  end

  test "evaluate ERb" do
    Page.create!(body: "<h1><%= \"foo\".reverse %></h1>", title: "test")
    get :show, params: { path: "test" }
    assert_select("h1", text: "oof")
  end

  test "use view helpers" do
    Page.create!(body: "<h1><%= number_to_currency(18.919, precision: 2) %></h1>", title: "test")
    get :show, params: { path: "test" }
    assert_select("h1", text: "$18.92")
  end

  test "use path-dependent view helpers" do
    root = Page.create!(body: "<h1>Welcome</h1>")
    root.children.create!(body: "<h1><%= link_to(\"Categories\", categories_path) %></h1>", title: "Sitemap")
    get :show, params: { path: "sitemap" }
    assert_select("a[href='/categories']", text: "Categories")
  end

  test "call partials" do
    Page.create!(body: "<h1>Mailing Lists</h1>\n<%= render partial: 'fake/flash_messages' %>", title: "lists")
    get :show, params: { path: "lists" }
    assert_select("p.flash_message")
  end

  test "call partials with concise syntax" do
    Page.create!(body: "<h1>Mailing Lists</h1>\n<%= render 'fake/flash_messages' %>", title: "lists")
    get :show, params: { path: "lists" }
    assert_select("p.flash_message")
  end

  def create_page
    FactoryBot.create(:page)
  end
end
