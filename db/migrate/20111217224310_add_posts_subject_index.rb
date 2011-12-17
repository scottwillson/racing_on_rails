class AddPostsSubjectIndex < ActiveRecord::Migration
  def self.up
    add_index_using_tmp_table :posts, :subject
  end

  def self.down
    remove_index_using_tmp_table :posts, :subject
  end
end
