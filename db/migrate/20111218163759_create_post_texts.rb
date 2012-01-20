class CreatePostTexts < ActiveRecord::Migration
  def self.up
    create_table :post_texts, :force => true, :options => "ENGINE=MyISAM", :force => true do |t|
      t.belongs_to :post, :null => false
      t.text :text
      t.timestamps
    end
    
    execute "insert into post_texts (text, post_id) select subject, id from posts"
    execute "create fulltext index post_text on post_texts (text)"
    add_index :post_texts, :post_id
  end

  def self.down
    remove_index :post_texts, :post_id
    remove_index :post_texts, :text
    drop_table :post_texts
  end
end