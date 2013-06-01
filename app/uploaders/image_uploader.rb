require "carrierwave/processing/mime_types"

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::RMagick
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper

  storage :file
  process :resize_to_limit => [ 2880, 1800 ]
  process :set_content_type
  process :save_dimensions

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def default_url
    asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  def save_dimensions
    if @file
      img = ::Magick::Image::read(@file.file).first
      if model
        model.width = img.columns
        model.height = img.rows
      end
    end
  end
end
