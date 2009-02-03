class CreateNewCategories < ActiveRecord::Migration
  def self.up
    create_table :new_categories, :force => true do |t|
      t.string :name
      t.string :type
      t.references :new_category
      t.integer :position, :null => false, :default => 999
      t.integer :lock_version, :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :new_categories
  end
end
