class FixWomenCategoryNames < ActiveRecord::Migration
  def self.up
    # Move all references from Category 3 Women (190) to Category Women 3 (6)
    # Delete Category 3 Women
    # Rename Category Women 3 to Category 3 Women
    
    Category.transaction do
      Category.connection.execute('update discipline_bar_categories set category_id=6 where category_id=190')
      Category.connection.execute('update races set category_id=6 where category_id=190')
      Category.connection.execute('update results set category_id=6 where category_id=190')

      Category.connection.execute('update discipline_bar_categories set category_id=7 where category_id=191')
      Category.connection.execute('update races set category_id=7 where category_id=191')
      Category.connection.execute('update results set category_id=7 where category_id=191')

      category_3_women = Category.find_by_name('Category 3 Women')
      Category.delete(category_3_women.id)

      category_women_3 = Category.find_by_name('Category Women 3')    
      category_women_3.name = 'Category 3 Women'
      category_women_3.save!

      category_4_women = Category.find_by_name('Category 4 Women')
      Category.delete(category_4_women.id)

      category_women_4 = Category.find_by_name('Category Women 4')    
      category_women_4.name = 'Category 4 Women'
      category_women_4.save!
    end
  end

  def self.down
  end
end
