class AddArticles < ActiveRecord::Migration
  def self.up
    return if ASSOCIATION.short_name == "MBRA"
    
    create_table :article_categories do |t|
      t.string :name
      t.integer :parent_id, :integer, :default => 0
      t.integer :position, :integer, :default => 0
      t.string :description

      t.timestamps
    end

    create_table :articles do |t|
      t.string :title
      t.string :heading
      t.string :description
      t.boolean :display
      t.text :body
      t.integer :position, :integer, :default => 0

      t.references :article_category
      t.timestamps
    end
  end

  def self.down
    drop_table :articles
    drop_table :article_categories
  end
end
