# frozen_string_literal: true

require_relative "../../test_case"
require_relative "../../../app/models/photos/dimensions"

# :stopdoc:
class Photos::DimensionsTest < Ruby::TestCase
  class TestPhoto
    include Photos::Dimensions
    attr_accessor :height, :width
  end

  def test_nil_safe
    photo = TestPhoto.new
    assert !photo.landscape?, "landscape?"
    assert !photo.portrait?, "portrait?"
    assert !photo.widescreen?, "widescreen?"
  end
end
