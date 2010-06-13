class AddResultCustomColumns < ActiveRecord::Migration
  def self.up
    change_table :results do |t|
      t.text :custom_attributes
    end
    change_table :races do |t|
      t.text :custom_columns
    end
  end

  def self.down
    change_table :results do |t|
      t.remove :custom_attributes
    end
    change_table :races do |t|
      t.remove :custom_columns
    end
  end
end