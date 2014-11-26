class RegeneratePhotos < ActiveRecord::Migration
  def change
    Photo.find_each do |photo|
      photo.image.recreate_versions! if photo.image?
    end
  end
end
