class AddCategoriesGender < ActiveRecord::Migration
  def change
    add_column :categories, :gender, :string, default: "M", null: false

    Category.reset_column_information
    Category.transaction do
      Category.all.each.with_index do |category, index|
        putc(".") if index % 100 == 0
        category.set_gender_from_name
        category.save!
      end
      puts
    end
  end
end
