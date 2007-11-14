class AddCategoryParams < ActiveRecord::Migration
  def self.up
    add_column :categories, :friendly_param, :string, :null => false
    Category.transaction do
      Category.find(:all).each do |category|
        p "#{category.name} #{category.to_friendly_param}"
        category.friendly_param = category.to_friendly_param
        category.save!
      end
      add_index :categories, :friendly_param
    end
  end

  def self.down
    begin
      remove_index :categories, :friendly_param
    rescue Exception => e
      p e
    end

    begin
      remove_column :categories, :friendly_param
    rescue Exception => e
      p e
    end
  end
end
