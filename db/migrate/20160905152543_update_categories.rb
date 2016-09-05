class UpdateCategories < ActiveRecord::Migration
  def change
    Category.update_all_from_names!
  end
end
