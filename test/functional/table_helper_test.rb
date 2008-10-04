require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + "/table_controller"

# Need some shenanigans to set up proper context for the helper.
class TableHelperTest < ActionController::TestCase
  tests TableController
  
  def test_empty_table
    setup_assigns([])
    setup_inline_template("<%= table(:events) %>")
    get(:table)
    assert_tag(:tag => "table", :children => { :count => 1, :only => { :tag => "tr" } })
    assert(@response.body["Empty"], "Empty table should include 'empty'")
  end
  
  def test_one_row
    setup_assigns([SingleDayEvent.create!])
    setup_inline_template("<%= table(:events) %>")
    get(:table)
    assert_tag(:tag => "table", :children => { :count => 1, :only => { :tag => "tr" } })
    assert(!@response.body["Empty"], "Empty table should not include 'empty'")
  end
  
  # TODO test bad params raise helpful error
  
  def setup_assigns(test_assigns)
    @controller.test_assigns = test_assigns
  end
  
  def setup_inline_template(inline_template)
    @controller.inline_template = inline_template
  end
end
