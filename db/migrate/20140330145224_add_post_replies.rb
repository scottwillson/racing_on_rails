class AddPostReplies < ActiveRecord::Migration
  def up
    change_table :posts do |t|
      t.datetime :last_reply_at, :null => true, :default => nil
      t.string :last_reply_from_name
      t.integer :original_id, :null => true, :default => nil
      t.integer :replies_count, :null => false, :default => 0
    end

    add_index :posts, :original_id
    add_index :posts, :last_reply_at
  end

  def down
    remove_column :posts, :last_reply_at
    remove_column :posts, :last_reply_from_name
    remove_column :posts, :original_id
    remove_column :posts, :replies_count
  end
end
