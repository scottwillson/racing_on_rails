class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.column :caption,      :string, :null => true
      t.column :html_options, :string, :null => true
      t.column :link,         :string, :null => true
      t.column :name,         :string, :null => false
      t.column :source,       :string, :null => false
    end
    add_index :images, :name, :unique => true
  end

  def self.down
    drop_table :images
  end
end
