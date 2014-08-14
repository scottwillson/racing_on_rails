class SetCategoryAges < ActiveRecord::Migration
  def change
    Category.transaction do
      Category.where(ages_begin: 0, ages_end: 999).each do |category|
        category.save!
      end
    end
  end
end
