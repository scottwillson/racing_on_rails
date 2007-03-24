class AddCompetitionCategories < ActiveRecord::Migration
  def self.up
    create_table :competition_categories, :id => false do |table|
      table.column :competition_id,       :integer,   :null => false,  :references => :events,     :on_delete => :cascade
      table.column :category_id,          :integer,   :null => false,                             :on_delete => :restrict
      table.column :parent_category_id,   :integer,   :null => false, :references => :categories, :on_delete => :restrict    
    end
    add_index(:competition_categories, [:competition_id, :category_id, :parent_category_id], :unique => true)
    
    add_column :categories, :parent_id, :integer, :null => true, :references => :categories, :on_delete => :set_null
    remove_index :categories, :name => :idx_category_name_scheme

    previous_categories = []
    for category in Category.find(:all, :order => :id)
      if category.bar_category and !previous_categories.include?(category.name)
        category.parent_id = category.bar_category.id
        category.position = category.bar_category.position
      end
      previous_categories << category.name
      category.save!
    end
    add_index(:categories, :name, :unique => true)
    
    remove_column :categories, :bar_category_id
    remove_column :categories, :is_overall
    remove_column :categories, :overall_id
    remove_column :categories, :scheme
  end

  def self.down
    drop_table :competition_categories
    remove_column :categories, :parent_id
  end
end
