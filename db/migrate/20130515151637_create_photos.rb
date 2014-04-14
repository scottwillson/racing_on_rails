class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos, force: true do |t|
      t.string :caption
      t.string :title
      t.string :image
      t.integer :height
      t.integer :width

      t.timestamps
    end
  end
end
