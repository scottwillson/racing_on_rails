class EnlargePhotoCaption < ActiveRecord::Migration
  def change
    change_column :photos, :caption, :string, :size => 2048
  end
end
