class AddAgeRangeToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :ages_begin, :integer, :default => 0
    add_column :categories, :ages_end, :integer, :default => 999
  end

  def self.down
  end
end
