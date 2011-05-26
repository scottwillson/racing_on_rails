class DropPageAuthor < ActiveRecord::Migration
  def self.up
    drop_table :page_versions
    execute("alter table pages drop foreign key pages_author_id") rescue nil
    remove_column :pages, :author_id
    add_column :pages, :created_by_id, :integer
    add_index :pages, :created_by_id
  end

  def self.down
    remove_index :pages, :created_by_id
    remove_column :pages, :created_by_type
    remove_column :pages, :created_by_id
    add_column :pages, :author_id, :integer
  end
end