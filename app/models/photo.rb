class Photo < ActiveRecord::Base
  include Concerns::Photo::Dimensions

  mount_uploader :image, ImageUploader

  validates_presence_of :caption, :image, :height, :width

  before_validation :set_title, on: :create

  def set_title
    if title.blank?
      self.title = caption
    end
  end
end
