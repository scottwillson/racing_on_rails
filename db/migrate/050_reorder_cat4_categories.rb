class ReorderCat4Categories < ActiveRecord::Migration
  def self.up
    return unless ASSOCIATION.short_name = "OBRA"
    
    Category.transaction do 
      obra = Category.find_by_name("OBRA")
      cat_4_5 = Category.find_by_name("Category 4/5 Men")
      cat_4_5.parent = obra
      cat_4_5.save!
      
      cat_4 = Category.find_by_name("Category 4 Men")
      cat_4.parent = cat_4_5
      cat_4.save!
      
      cat_5 = Category.find_by_name("Category 5 Men")
      cat_5.parent = cat_4_5
      cat_5.save!
    end
  end

  def self.down
  end
end
