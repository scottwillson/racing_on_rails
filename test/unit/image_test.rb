require File.dirname(__FILE__) + '/../test_helper'

class ImageTest < ActiveSupport::TestCase
  fixtures :images

  def test_validation
    assert(!Image.new(:name => 'Photo').valid?, 'image with no source should not be valid')
    assert(!Image.new(:source => 'photo.gif').valid?, 'image with no name should not be valid')
    assert(Image.new(:name => 'Photo', :source => 'photo.gif').valid?, 'image with no URL should  be valid')
    assert(Image.new(:name => 'Photo', :source => 'photo.gif', :link => 'http://STATIC_HOST/images/photo.gif').valid?, 'image with  URL should  be valid')
    assert(!Image.new(:source => images(:photo).name, :source => 'photo.gif').valid?, 'image with duplicate name should not be valid')
  end
end
