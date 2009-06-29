require 'test_helper'

ActionController::Base.prepend_view_path("#{RAILS_ROOT}/test/fixtures/views")

class FakeController < ApplicationController
  def nil_attribute
    @event = Event.new
    render :template => "fake/event.html.erb"
  end

  def present_attribute
    @event = Event.new(:promoter => Person.create!(:name => "Tony Kic"))
    render :template => "fake/event.html.erb"
  end
end

class AutoCompleteHelperTest < ActionController::TestCase
  tests FakeController
    
  def test_auto_complete_nil_attribute
    get :nil_attribute
    assert_select "input#promoter_auto_complete" do
      assert_select "[value=?]", ""
    end
  end
    
  def test_auto_complete_attribute_present
    get :present_attribute
    assert_select "input#promoter_auto_complete" do
      assert_select "[value=?]", "Tony Kic"
    end
    assert_select "input#event_promoter_id" do
      assert_select "[value=?]", /\d+/
    end
  end
end
