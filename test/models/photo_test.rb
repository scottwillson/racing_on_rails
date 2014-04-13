require 'test_helper'

class PhotoTest < ActiveSupport::TestCase
  test "create" do
    FactoryGirl.create :photo
  end

  test "set_title on validate from caption" do
    photo = Photo.new(:caption => "Foo")
    photo.valid?
    assert_equal "Foo", photo.title, "title"
  end

  test "validation" do
    photo = Photo.new
    photo.valid?
    assert photo.errors[:caption]
    assert photo.errors[:image]
    assert photo.errors[:height]
    assert photo.errors[:width]
  end
end
