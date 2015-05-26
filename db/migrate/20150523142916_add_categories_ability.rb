class AddCategoriesAbility < ActiveRecord::Migration
  def change
    add_column(:categories, :ability, :integer, default: 0, null: false) rescue nil

    Category.reset_column_information
    Category.transaction do
      Category.all.each.with_index do |category, index|
        putc(".") if index % 100 == 0
        category.set_ability_from_name
        category.save!
      end
      puts
    end
  end
end
