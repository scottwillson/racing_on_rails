class CleanUpMbraCategories < ActiveRecord::Migration
  def self.up
    #this is to clean up a bug that generated some duplicate categories by inserting multiple spaces in the generated category name
    return unless ASSOCIATION.short_name == "MBRA"

    Category.find.all().each do |category|
      if category.name != category.name.squeeze(" ").strip
        good_category = Category.first(:conditions => {:name => category.name.squeeze(" ").strip} )
        if good_category.blank?
          #fix the existing catg name
          say "fixing " + category.name
          category.name = category.name.squeeze(" ").strip
          category.save!
        else
          #change the category for all races with this catg and delete this catg
          say "replacing '" + category.name + "' with '" + good_category.name + "'"
          execute "update races set category_id = #{good_category.id} where category_id = #{category.id}"
          Category.delete(category.id)
        end
      end
    end

  end

  def self.down
  end
end
