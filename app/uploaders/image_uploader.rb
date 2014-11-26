require "carrier_wave/mini_magick/processing"

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  version :original

  version :desktop do
    process resize_to_limit: [ 1440, 900 ]
    process quality: 85
    process :interlace
    process :save_dimensions
  end

  version :mobile do
    process resize_to_limit: [ 480, 320 ]
    process quality: 85
    process :interlace
  end

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
    if file && model
      model.width, model.height = ::MiniMagick::Image.open(file.file)[:dimensions]
    end
  end
end
