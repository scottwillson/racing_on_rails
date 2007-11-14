class UpdateCat5Position < ActiveRecord::Migration
  def self.up
    cat_5 = Category.find(145)
    cat_5.position = 50
    cat_5.save!
  end

  def self.down
  end
end
