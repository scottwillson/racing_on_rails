class UpdateCat5Position < ActiveRecord::Migration
  def self.up
    cat_5 = Category.find_by_name('Category 5 Men')
    if cat_5
      cat_5.position = 50
      cat_5.save!
    end
  end

  def self.down
  end
end
