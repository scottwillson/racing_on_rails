class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages, :force => true do |t|
      t.integer :parent_id, :default => nil
      t.text :body, :default => "", :null => false
      t.string :path, :default => "", :null => false
      t.string :slug, :default => "", :null => false
      t.string :title, :default => "", :null => false
      
      t.timestamps
    end
    
    add_index :pages, :path, :unique => true
  end

  def self.down
    remove_index :pages, :column => :path
    drop_table :pages
  end
end
