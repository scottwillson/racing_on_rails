require File.expand_path("../../test_helper", __FILE__)

ActionController::Base.prepend_view_path "#{Rails.root}/test/fixtures/views"

# :stopdoc:
class FakeController < ApplicationController
  def index
    render_page
  end

  def recent_results
    render_page
  end

  def upcoming_events
    render_page("home_upcoming_events")
  end

  def news
    @news_summary = "Masters want more BAR points"
    render_page
  end

  def partial_using_action
    render template: "fake/partial_using_action"
  end

  def partial_using_partials_action
    render template: "fake/partial_using_partials_action"
  end

  def missing_partial
    render template: "fake/missing_partial"
  end
end

class PagesActionControllerIntegrationTest < ActionController::TestCase
  tests FakeController

  setup :create_page

  test "work as a partial" do
    get(:partial_using_action)
    assert_select("p", text: "This is a plain page")
    assert_template layout: "application"
  end

  test "raise exception for missing partial" do
    # Would prefer MissingTemplate
    assert_raise(ActionView::TemplateError) { get(:missing_partial) }
  end

  test "work as a partial and all partials itself" do
    get(:partial_using_partials_action)
    assert_select("p", text: "This is a plain page")
    assert_select("p.flash_message")
    assert_template layout: "application"
  end

  test "replace file based template for controllers" do
    page = Page.create!(title: "fake").children.create!(title: "recent_results", body: "<em>Results</em>")
    assert_equal("fake/recent_results", page.path, "Page path")
    get(:recent_results)
    assert_select("em", text: "Results")
    assert_template layout: "application"
  end

  test "replace file based template for controllers index" do
    Page.create!(title: "fake", body: "<em>Homepage!</em>")
    get(:index)
    assert_select("em", text: "Homepage!")
    assert_template layout: "application"
  end

  test "replace file based template for controllers with explicit path" do
    Page.create!(title: "home_upcoming_events", body: "<em>Upcoming Events</em>")
    get(:upcoming_events)
    assert_select("em", text: "Upcoming Events")
    assert_template layout: "application"
  end

  test "use controller assigns" do
    Page.create!(title: "fake").children.create!(title: "news", body: "<h4><%= @news_summary %></h4>")
    get(:news)
    assert_select("h4", text: "Masters want more BAR points")
    assert_template layout: "application"
  end

  def create_page
    FactoryGirl.create(:page)
  end
end
