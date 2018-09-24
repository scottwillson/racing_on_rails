# frozen_string_literal: true

class Photo < ApplicationRecord
  include Photos::Dimensions

  mount_uploader :image, ImageUploader

  validates :caption, :image, :height, :width, presence: true

  before_validation :set_title, on: :create

  def set_title
    self.title = caption if title.blank?
  end
end
