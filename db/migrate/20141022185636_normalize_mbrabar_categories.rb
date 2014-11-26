class NormalizeMbrabarCategories < ActiveRecord::Migration
  def change
    if RacingAssociation.current.short_name == "MBRA"
      Discipline.transaction do
        Discipline.all.each do |discipline|
          discipline.bar_categories.each do |category|
            normalized_name = Category.normalized_name(category.name)
            if normalized_name != category.name
              p "Swapping #{category.name} for #{normalized_name}"
              discipline.bar_categories.delete category
              discipline.bar_categories << Category.find_or_create_by(name: normalized_name)
            end
          end
        end
      end
    end
  end
end
