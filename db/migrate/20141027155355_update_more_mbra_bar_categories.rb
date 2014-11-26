class UpdateMoreMbraBarCategories < ActiveRecord::Migration
  def change
    if RacingAssociation.current.short_name == "MBRA"
      Discipline.transaction do
        Competitions::MbraBar.year(2014).each(&:destroy_races)
        [
          "{:Name=>\"Masters Men 40+\"}",
          "{:Name=>\"Masters Men 50+\"}",
          "{:Name=>\"Masters Men 60+\"}",
          "{:Name=>\"Masters Women 40+\"}",
          "{:Name=>\"Masters Women 50+\"}"
        ].each do |name|
          category = Category.where(name: name).first
          if category
            category.races.each(&:destroy!)
            category.destroy!
          end
        end

        %w{ Road Cyclocross }.each do |discipline_name|
          discipline = Discipline.where(name: discipline_name).first
          [ 
            "Masters Men 40+",
            "Masters Men 50+",
            "Masters Men 60+",
            "Masters Women 40+"
          ].each do |name|
            category = Category.find_or_create_by_normalized_name(name)
            unless discipline.bar_categories.include?(category)
              discipline.bar_categories << category
            end
          end
        
          discipline.bar_categories.delete Category.find_or_create_by_normalized_name("Masters A Men")
          discipline.bar_categories.delete Category.find_or_create_by_normalized_name("Masters B Men")
        end
        
        discipline = Discipline.where(name: "Mountain Bike").first
        [ 
          "Masters Men 50+",
          "Masters Women 50+"
        ].each do |name|
          category = Category.find_or_create_by_normalized_name(name)
          unless discipline.bar_categories.include?(category)
            discipline.bar_categories << category
          end
        end
        
        Category.cleanup!
      end
    end
  end
end
