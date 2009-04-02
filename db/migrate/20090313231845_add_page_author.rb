class AddPageAuthor < ActiveRecord::Migration
  def self.up
    add_column :pages, :author_id, :integer
  end

  def self.down
    remove_column :pages, :author_id
  end
end
