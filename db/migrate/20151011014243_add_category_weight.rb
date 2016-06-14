class AddCategoryWeight < ActiveRecord::Migration
  require "category"

  class Category < ::Category
    def set_equipment_from_name
    end
  end

  def change
    add_column :categories, :weight, :string, null: true, default: nil
    add_index :categories, :weight

    Category.reset_column_information
    Category.transaction do
      Category.all.each do |category|
        category.set_weight_from_name
        category.save!
      end
    end
  end
end
