class AddCompetitionCategories < ActiveRecord::Migration
  def self.up
    create_table :competition_categories, :id => false do |table|
      table.column :competition_id,       :int,   :null => true, :references => :events, :on_delete => :cascade
      table.column :category_id,          :int,   :null => false, :on_delete => :restrict
      table.column :source_category_id,   :int,   :null => false, :references => :categories, :on_delete => :restrict    
    end
    add_index(:competition_categories, [:competition_id, :category_id, :source_category_id], :unique => true)
  end

  def self.down
    drop_table :competition_categories
  end
end
