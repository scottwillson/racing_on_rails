require_relative "../../../test_case"
require_relative "../../../../../app/models/concerns/photo/dimensions"

# :stopdoc:
class Concerns::Photo::DimensionsTest < Ruby::TestCase
  class TestPhoto
    include Concerns::Photo::Dimensions
    attr_accessor :height, :width
  end

  def test_nil_safe
    photo = TestPhoto.new
    assert !photo.landscape?, "landscape?"
    assert !photo.portrait?, "portrait?"
    assert !photo.widescreen?, "widescreen?"
  end
end