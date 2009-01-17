class ConsolidateBarAgeCategories < ActiveRecord::Migration
  def self.up
    ["Mountain Bike", "Downhill"].each do |discipline_name|
      discipline = Discipline[discipline_name]
      discipline.bar_categories.clear
      
      discipline.bar_categories << Category.find_by_name("Singlespeed/Fixed")
      discipline.bar_categories << Category.find_by_name("Pro, Semi-Pro Men")
      discipline.bar_categories << Category.find_by_name("Expert Men")
      discipline.bar_categories << Category.find_by_name("Sport Men")
      discipline.bar_categories << Category.find_by_name("Beginner Men")
      discipline.bar_categories << Category.find_by_name("Pro, Expert Women")
      discipline.bar_categories << Category.find_by_name("Sport Women")
      discipline.bar_categories << Category.find_by_name("Beginner Women")
      discipline.bar_categories << Category.find_by_name("Junior Men")
      discipline.bar_categories << Category.find_by_name("Junior Women")
      discipline.bar_categories << Category.find_by_name("Masters Men")
      discipline.bar_categories << Category.find_by_name("Masters Women")
    end
  end

  def self.down
  end
end
