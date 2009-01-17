class ConsolidateBarAgeCategories < ActiveRecord::Migration
  def self.up
    ["Mountain Bike", "Downhill"].each do |discipline_name|
      discipline = Discipline[discipline_name]
      
      if discipline
        discipline.bar_categories.clear
        
        [ "Singlespeed/Fixed",
          "Pro, Semi-Pro Men",
          "Expert Men",
          "Sport Men",
          "Beginner Men",
          "Pro, Expert Women",
          "Sport Women",
          "Beginner Women",
          "Junior Men",
          "Junior Women",
          "Masters Men",
          "Masters Women"  ].each do |category_name|
          category = Category.find_by_name(category_name)
          (discipline.bar_categories << category) if category
        end
      end
    end
  end

  def self.down
  end
end
