class ExpandPhotoCaption < ActiveRecord::Migration
  def up
    change_column :photos, :caption, :text
  end

  def down
    change_column :photos, :caption, :string
  end
end