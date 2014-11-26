class ImportPosts < ActiveRecord::Migration
  def change
    Post.import
  end
end
