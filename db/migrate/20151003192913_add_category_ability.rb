class AddCategoryAbility < ActiveRecord::Migration
  def change
    add_column :categories, :ability_begin, :integer, null: false, default: 0
    add_column :categories, :ability_end, :integer, null: false, default: 999
    add_index :categories, :ability_begin
    add_index :categories, :ability_end
    remove_column :categories, :ability
  end
end
