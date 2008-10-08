require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + "/tables_controller"

# Need some shenanigans to set up proper context for the helper.
module TableHelper
  class TableHelperTest < ActionController::TestCase
    tests Admin::TablesController
    
    def test_empty_table
      use_assigns([])
      use_inline_template("<%= table(:events) %>")
      get(:index)
      assert_tag(:tag => "table", :children => { :count => 2, :only => { :tag => "tr" } })
      assert(@response.body["Empty"], "Empty table should include 'empty'")
    end
  
    def test_one_row
      use_assigns([SingleDayEvent.create!])
      use_inline_template("<%= table(:events) %>")
      get(:index)
      assert_tag(:tag => "table", :children => { :count => 2, :only => { :tag => "tr" } })
      assert(!@response.body["Empty"], "Empty table should not include 'empty'")
    end
  
    def test_rows_with_name
      events = [
        SingleDayEvent.create!(:name => "Silverton"),
        SingleDayEvent.create!(:name => "Alpenrose")
      ]
      use_assigns(events)
      use_inline_template("<%= table(:events) do |t| t.column :name end %>")
      get(:index)
      assert_tag(:tag => "table", :children => { :count => 3, :only => { :tag => "tr" } })
      assert_tag(:tag => "tr", :children => { :count => 1, :only => { :tag => "td" } })
      assert_tag(:tag => "th", :content => "Name")
      assert_tag(:tag => "td", :content => "Alpenrose")
      assert_tag(:tag => "td", :content => "Silverton")
    end
  
    def test_rows_with_many_columns
      events = [
        SingleDayEvent.create!(:name => "Silverton", :date => Date.new(2009, 7, 4), :first_aid_provider => "------------", :city => "Silverton", :state => "OR"),
        SingleDayEvent.create!(:name => "Alpenrose", :date => Date.new(2009, 10, 5), :first_aid_provider => "Andrea Fisk [justri2catchme@hotmail.com]", 
                               :city => "Portland", :state => "OR")
      ]
      use_assigns(events)
      use_inline_template(%Q{<%= table(:events) do |t| 
                                   t.column :first_aid_provider, :title => 'Provider', :editable => true
                                   t.column :name, :link => true
                                   t.column :date, :format => :short_with_week_day
                                   t.column :city_state, :title => 'Location'
                                 end %>}
      )
      get(:index)
      assert_tag(:tag => "table", :children => { :count => 3, :only => { :tag => "tr" } })
      assert_tag(:tag => "tr", :children => { :count => 4, :only => { :tag => "td" } })
      assert_tag(:tag => "th", :content => "Provider")
      assert_tag(:tag => "th", :content => "Name")
      assert_tag(:tag => "th", :content => "Name")
      assert_tag(:tag => "th", :content => "Location")
      assert_tag(:tag => "td", :content => "Alpenrose")
      assert_tag(:tag => "td", :content => "Andrea Fisk [justri2catchme@hotmail.com]")
      assert_tag(:tag => "td", :content => "Portland, OR")
      assert_tag(:tag => "td", :content => "Sat 07/04")
      assert_tag(:tag => "a", :attributes => { :href => admin_event_path(events.first)})
      assert_tag(:tag => "td", :children => { :count => 1, :only => { :tag => "span" } })
    end
  
    # TODO test bad params raise helpful error
    def test_caption
      use_assigns([])
      use_inline_template("<%= table(:events, :caption => 'My Table Caption') %>")
      get(:index)
      assert_tag(:tag => "caption", :content => "My Table Caption")
    end
    
    def use_assigns(test_assigns)
      @controller.test_assigns = test_assigns
    end
  
    def use_inline_template(inline_template)
      @controller.inline_template = inline_template
    end
  end
end