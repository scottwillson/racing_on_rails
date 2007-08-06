class CreateNewsItems < ActiveRecord::Migration
  def self.up
    create_table :news_items do |t|
      t.column :date,          :date,       :null => false
      t.column :text,          :string,     :null => false
      t.column :lock_version,  :int,        :null => false, :default => 0
      t.column :created_at,    :datetime
      t.column :updated_at,    :datetime
    end
    add_index :news_items, :date
    add_index :news_items, :text
  end

  def self.down
    drop_table :news_items
  end
end
