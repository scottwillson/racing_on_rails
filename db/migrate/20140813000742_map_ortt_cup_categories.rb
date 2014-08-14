class MapOrttCupCategories < ActiveRecord::Migration
  def change
    Category.transaction do
      Category.where("name like ?", "%eddie%").each do |category|
        category.name = category.name.gsub("Eddie", "Eddy")
        existing_category = Category.where(name: category.name).where.not(id: category.id).first
        if existing_category
          category.replace_with existing_category
        else
          category.save!
        end
      end

      [ "Eddy", "Eddy Men", "Men Eddy", "Men Eddy Merckx" ].each do |category_name|
        category = Category.where(name: category_name).first
        if category
          parent = Category.where(name: "Eddy Senior Men").first
          category.parent = parent
          category.save!
        end
      end

      [ "Eddy Women", "Women Eddy", "Women Eddy Merckx" ].each do |category_name|
        category = Category.where(name: category_name).first
        if category
          parent = Category.where(name: "Eddy Senior Women").first
          category.parent = parent
          category.save!
        end
      end
    end
  end
end
