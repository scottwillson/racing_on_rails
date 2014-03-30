class AddPostReplies < ActiveRecord::Migration
  def up
    change_table :posts do |t|
      t.datetime :last_reply_at, :null => true, :default => nil
      t.integer :original_id, :null => true, :default => nil
      t.integer :replies_count, :null => false, :default => 0
    end

    add_index :posts, :original_id
  end

  def down
    remove_column :posts, :original_id
  end
end
