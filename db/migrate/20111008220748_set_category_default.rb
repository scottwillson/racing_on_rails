class SetCategoryDefault < ActiveRecord::Migration
  def self.up
    change_column_default :categories, :name, ""
  end

  def self.down
    change_column_default :categories, :name, nil
  end
end