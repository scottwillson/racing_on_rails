class PageActsAsVersioned < ActiveRecord::Migration
  def self.up
    add_column :pages, :lock_version, :integer, :default => 0, :null => false
    create_table :page_versions, :force => true do |t|
      t.integer :page_id, :null => false
      t.integer :parent_id
      t.integer :author_id
      t.text :body
      t.string :path
      t.string :slug
      t.string :title
      t.integer :lock_version
      t.timestamps
    end
  end

  def self.down
    drop_table :page_versions
    remove_column :pages, :lock_version
  end
end
