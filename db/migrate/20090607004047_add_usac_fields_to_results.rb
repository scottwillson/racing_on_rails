class AddUsacFieldsToResults < ActiveRecord::Migration
  def self.up
    return if ASSOCIATION.short_name == "MBRA"
    add_column :results, :gender, :string, :limit => 8
    add_column :results, :category_class, :string, :limit => 16
    add_column :results, :age_group, :string, :limit => 16
  end

  def self.down
    remove_column :results, :gender
    remove_column :results, :category_class
    remove_column :results, :age_group
  end
end
