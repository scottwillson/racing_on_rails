class SimplifyCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :parent_id, :integer, :null => true, :references => :categories, :on_delete => :set_null
    remove_index :categories, :name => :idx_category_name_scheme

    previous_categories = []
    categories_to_delete = []
    for category in Category.find(:all, :order => ['scheme, id'])
      previous_category = previous_categories.detect {|cat| cat.name == category.name}
      if previous_category
        Race.update_all("category_id = #{previous_category.id}", "category_id = #{category.id}")
        Result.update_all("category_id = #{previous_category.id}", "category_id = #{category.id}")
        categories_to_delete << category.id
      elsif category.bar_category
        if category.bar_category_id == category.id
          category.parent_id = nil
        else
          category.parent_id = category.bar_category.id
        end
        category.position = category.bar_category.position
      end
      previous_categories << category
      category.save!
    end
    for category in categories_to_delete
      Category.delete(categories_to_delete)
    end
    add_index(:categories, :name, :unique => true)
    
    remove_column :categories, :bar_category_id
    remove_column :categories, :is_overall
    remove_column :categories, :overall_id
    remove_column :categories, :scheme
  end

  def self.down
    remove_column :categories, :parent_id
    remove_index :categories, :name
    add_index(:categories, :name, :unique => true)
  end
end
