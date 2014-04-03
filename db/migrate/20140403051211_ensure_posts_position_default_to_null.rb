class EnsurePostsPositionDefaultToNull < ActiveRecord::Migration
  def up
    change_column :posts, :position, :integer, :default => nil, :null => true
  end

  def down
    change_column :posts, :position, :integer, :default => nil, :null => true
  end
end