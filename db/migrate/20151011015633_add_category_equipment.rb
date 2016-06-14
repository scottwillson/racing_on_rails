class AddCategoryEquipment < ActiveRecord::Migration
  def change
    add_column :categories, :equipment, :string, null: true, default: nil
    add_index :categories, :equipment

    Category.transaction do
      Category.all.each do |category|
        category.set_equipment_from_name
        category.save!
      end
    end
  end
end
