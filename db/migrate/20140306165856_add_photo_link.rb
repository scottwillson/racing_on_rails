# frozen_string_literal: true

class AddPhotoLink < ActiveRecord::Migration
  def up
    add_column :photos, :link, :string
  end

  def down
    remove_column :photo, :link
  end
end
