class UpdateBarCategories < ActiveRecord::Migration
  def self.up
    execute("alter table categories alter column name drop default")

    [Discipline[:mountain_bike], Discipline[:downhill]].each do |discipline|
      discipline.bar_categories.clear
      [ "Pro Men", "Category 1 Men", "Category 2 Men", "Category 3 Men", "Pro Women", "Category 1 Women", "Category 2 Women", "Category 3 Women", "Masters Men", "Masters Women","Junior Men", "Junior Women", "Singlespeed/Fixed" ].each do |name|
        discipline.bar_categories << Category.find_or_create_by_name(name)
        discipline.save!
      end
    end
    
    cat = Category.find_by_name("Pro Men")
    cat.parent = Category.find_by_name("Senior Men")
    cat.position = 6
    cat.save!
    
    cat = Category.find_by_name("Category 1 Men")
    cat.position = 7
    cat.save!
    
    cat = Category.find_by_name("Category 2 Men")
    cat.position = 8
    cat.save!
    
    cat = Category.find_by_name("Pro Women")
    cat.parent = Category.find_by_name("Senior Women")
    cat.position = 50
    cat.save!
    
    cat = Category.find_by_name("Category 1 Women")
    cat.position = 51
    cat.save!
    
    cat = Category.find_by_name("Category 2 Women")
    cat.position = 52
    cat.save!
    
  end

  def self.down
  end
end
