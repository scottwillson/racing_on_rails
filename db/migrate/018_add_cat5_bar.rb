class AddCat5Bar < ActiveRecord::Migration
  def self.up
    if ASSOCIATION.short_name == 'OBRA'
      Category.transaction do
        cat_4_5_men = Category.find_by_name('Category 4/5 Men')
        cat_4_5_men.parent = nil
        cat_4_5_men.save!

        obra = Category.find_by_name('OBRA')
        cat_4_men = Category.find_by_name('Category 4 Men')
        cat_4_men.parent = obra
        cat_4_men.save!

        cat_5_men = Category.find_by_name('Category 5 Men')
        cat_5_men.parent = obra
        cat_5_men.save!

        cat_5_categories = ['Cat 5', 'Cat 5 Men', 'Category 5', 'Category5 Men', 'Men 5', 'Men Category 5', 'Senior Men 5', 'Senior Men Category 5',
          'Senior Men Category 5 11:30 Start', 'True Beginner', 'Men Cat 5']
        for name in cat_5_categories
          category = Category.find_by_name(name)
          category.parent = cat_5_men
          category.save!
        end
        
        for category in cat_4_5_men.children
          category.parent = cat_4_men
          category.save!
        end
        
        for discipline in Discipline.find(:all)
          if discipline.bar_categories.include?(cat_4_5_men)
            discipline.bar_categories.delete(cat_4_5_men)
            discipline.bar_categories << cat_4_men
            discipline.bar_categories << cat_5_men
          end
        end

        cat_4_5_men.parent = cat_4_men
        cat_4_5_men.save!
      end
    end
  end

  def self.down
  end
end
