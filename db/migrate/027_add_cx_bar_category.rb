class AddCxBarCategory < ActiveRecord::Migration
  def self.up
    cx = Discipline.find_by_name('Cyclocross')
    beginner = Category.find_by_name('Beginner Men')
    cx.bar_categories.delete(beginner)
    cat_5 = Category.find_by_name('Category 5 Men')
    beginner_cx = Category.find_or_create_by_name('Beginner Men CX')
    if beginner_cx.parent != cat_5
      beginner_cx.parent = cat_5
      beginner_cx.save!
    end
    cx.bar_categories << beginner_cx
  end

  def self.down
  end
end
