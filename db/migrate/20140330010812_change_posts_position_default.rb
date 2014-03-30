class ChangePostsPositionDefault < ActiveRecord::Migration
  def up
    change_column :posts, :position, :integer, :default => nil, :null => false
  end

  def down
    change_column :posts, :position, :integer, :default => 0, :null => false
  end
end
