require File.dirname(__FILE__) + '/../test_helper'

# :stopdoc:
class ApplicationHelperControllerTest < Test::Unit::TestCase
  
  include ApplicationHelper
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  
  fixtures :images
  
  def setup
    @controller = HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_image
    get(:index)
    photo = images(:photo)
    html = image(photo.name)
    assert_match(photo.source, html, 'Should contain image source')
  end

  def test_image_with_link
    get(:index)
    photo_with_link = images(:photo_with_link)
    html = image(photo_with_link.name)
    assert_match(photo_with_link.source, html, 'Should contain image source')
    assert_match('auction/home', html, 'Should contain image link')
  end

  def test_image_with_http_link
    get(:index)
    photo_with_link = images(:photo_with_http_link)
    html = image(photo_with_link.name)
    assert_match(photo_with_link.source, html, 'Should contain image source')
    assert(html['steelmancycles.com'], 'Should contain image link')
  end
  
  def test_nil_name
    get(:index)
    html = image(nil)
    assert(html.blank?, 'nil name should return blank string')
  end
  
  def test_not_found
    get(:index)
    html = image('some bogus name')
    assert_match('clear', html, 'Should contain clear.gif')
    assert(!html['href'], 'Should have no link')
  end
end