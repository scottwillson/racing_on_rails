require 'test_helper'

ActionController::Base.prepend_view_path("test/fixtures/views")

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
    render :template => "fake/partial_using_action.html.erb"
  end

  def partial_using_partials_action
    render :template => "fake/partial_using_partials_action.html.erb"
  end

  def missing_partial
    render :template => "fake/missing_partial.html.erb"
  end
end

class PagesActionControllerIntegrationTest < ActionController::TestCase
  tests FakeController
  
  def test_work_as_a_partial
    get(:partial_using_action)
    assert_select("p", :text => "This is a plain page")
    assert_layout("application")
  end
  
  def test_raise_exception_for_missing_partial
    # Would prefer MissingTemplate
    assert_raise(ActionView::TemplateError) { get(:missing_partial) }
  end
  
  def test_work_as_a_partial_and_all_partials_itself
    get(:partial_using_partials_action)
    assert_select("p", :text => "This is a plain page")
    assert_select("p.flash_message")
    assert_layout("application")
  end

  def test_replace_file_based_template_for_controllers
    page = Page.create!(:title => "fake").children.create!(:title => "recent_results", :body => "<em>Results</em>")
    assert_equal("fake/recent_results", page.path, "Page path")
    get(:recent_results)
    assert_select("em", :text => "Results")
    assert_layout("application")
  end

  def test_replace_file_based_template_for_controllers_index
    Page.create!(:title => "fake", :body => "<em>Homepage!</em>")
    get(:index)
    assert_select("em", :text => "Homepage!")
    assert_layout("application")
  end

  def test_replace_file_based_template_for_controllers_with_explicit_path
    Page.create!(:title => "home_upcoming_events", :body => "<em>Upcoming Events</em>")
    get(:upcoming_events)
    assert_select("em", :text => "Upcoming Events")
    assert_layout("application")
  end

  def test_use_controller_assigns
    Page.create!(:title => "fake").children.create!(:title => "news", :body => "<h4><%= @news_summary %></h4>")
    get(:news)
    assert_select("h4", :text => "Masters want more BAR points")
    assert_layout("application")
  end
end
