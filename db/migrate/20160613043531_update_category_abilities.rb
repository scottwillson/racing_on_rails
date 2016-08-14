class UpdateCategoryAbilities < ActiveRecord::Migration
  def change
    ::Category.transaction do
      Category.all.each do |category|
        category.set_ability_range_from_name
        category.ages = category.ages_from_name(category.name)
        category.save!
      end
    end
  end
end
