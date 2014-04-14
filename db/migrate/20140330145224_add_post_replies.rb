class AddPostReplies < ActiveRecord::Migration
  def up
    change_table :posts do |t|
      t.string :from_name, default: nil
      t.string :from_email, default: nil
      t.datetime :last_reply_at, null: true, default: nil
      t.string :last_reply_from_name
      t.integer :original_id, null: true, default: nil
      t.integer :replies_count, null: false, default: 0
    end

    Post.reset_column_information
    Post.select([:id, :sender]).each do |post|
      Post.where(id: post["id"]).update_all(
        from_email: post["sender"][/<(.*)>/, 1].try(:strip),
        from_name: post["sender"][/^([^<]+)/].try(:strip)
      )
    end

    add_index :posts, :original_id
    add_index :posts, :last_reply_at

    remove_column :posts, :sender
  end

  def down
    remove_column :posts, :last_reply_at
    remove_column :posts, :from_email
    remove_column :posts, :from_name
    remove_column :posts, :last_reply_from_name
    remove_column :posts, :original_id
    remove_column :posts, :replies_count

    add_column :posts, :sender, :string
  end
end
