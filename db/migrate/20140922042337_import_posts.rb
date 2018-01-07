# frozen_string_literal: true

class ImportPosts < ActiveRecord::Migration
  def change
    Post.import
  end
end
