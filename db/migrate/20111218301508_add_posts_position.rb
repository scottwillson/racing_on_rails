class AddPostsPosition < ActiveRecord::Migration
  def self.up
    change_table :posts do |t|
      t.integer :position, :default => 0, :null => false
    end
    
    Post.order("date, id").all.each_with_index do |post, index|
      if index % 1000 == 0
        say index
      end
      post.update_attributes!(:position => index)
    end

    add_index :posts, :position
  end

  def self.down
    remove_index :posts, :position
    change_table :posts do |t|
      t.remove :position
    end
  end
end