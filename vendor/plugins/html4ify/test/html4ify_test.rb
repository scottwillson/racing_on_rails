require 'test/unit'

require 'rubygems'

require 'active_support'
require 'action_view/helpers/tag_helper'
require 'action_view/helpers/active_record_helper'
require 'action_view/helpers/asset_tag_helper'

require File.dirname(__FILE__) + '/../lib/html4ify'

class Html4ifyTest < Test::Unit::TestCase
  include Html4ify, ActionView::Helpers::TagHelper, ActionView::Helpers::ActiveRecordHelper, ActionView::Helpers::AssetTagHelper
  
  HTML4_STRICT = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">"
  HTML4_LOOSE = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">"
  HTML4_FRAMESET = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Frameset//EN\" \"http://www.w3.org/TR/html4/frameset.dtd\">"
  XHTML11_STRICT = "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">"
 
  # Test the various DTD's
  def test_html4_strict
    assert_equal HTML4_STRICT, doctype(:html4, :strict)
  end
  
  def test_html4_loose
    assert_equal HTML4_LOOSE, doctype(:html4, :loose)
  end
  
  def test_html4_frameset
    assert_equal HTML4_FRAMESET, doctype(:html4, :frameset)
  end
  
  def test_xhtml11_strict
    assert_equal XHTML11_STRICT, doctype(:xhtml11, :strict)
  end
  
  def test_html4_strict_as_default
    assert_equal HTML4_STRICT, doctype
  end
  
  def test_tag_method_should_render_open_tag_by_default
    assert_open_tag tag(:test)
  end
  
  def test_tag_method_should_still_render_closed_tag
    assert_match %r{/>$}, tag(:test, {}, false)
  end
  
  def test_asset_helper_tags_should_be_rendered_open
    assert_open_tag auto_discovery_link_tag
    assert_open_tag image_tag('test.png')
    assert_open_tag stylesheet_link_tag(:test)
  end
  
  def test_form_helper_instance_tag_class_should_render_open_tag
    assert_open_tag ActionView::Helpers::InstanceTag.new(nil, nil, nil).tag(:foo, {})
    assert_open_tag ActionView::Helpers::InstanceTag.new(:foo, :bar, nil).to_input_field_tag(:test)
  end
  
private
  def assert_open_tag(snippet)
    assert_match %r{>$}, snippet
    assert_no_match %r{/>$}, snippet
  end
  
  # Fool auto_discovery_link_tag helper.
  def url_for(*args)
    'http://test.net'
  end
  
  # Fool image_tag helper.
  def compute_public_path(*args)
    '/'
  end
end
