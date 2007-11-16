class AddAgeGradedBarCategories < ActiveRecord::Migration
  def self.up
    AgeGradedBar.new.categories
  end

  def self.down
  end
end
