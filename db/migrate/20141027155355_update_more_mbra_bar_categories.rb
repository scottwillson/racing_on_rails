class UpdateMoreMbraBarCategories < ActiveRecord::Migration
  def change
    if RacingAssociation.current.short_name == "MBRA"
      Discipline.transaction do
        Competitions::MbraBar.year(2014).each(&:destroy_races)
        Category.where(name: "{:Name=>\"Masters Men 40+\"}").first.destroy!
        Category.where(name: "{:Name=>\"Masters Men 50+\"}").first.destroy!
        Category.where(name: "{:Name=>\"Masters Men 60+\"}").first.destroy!
        Category.where(name: "{:Name=>\"Masters Women 40+\"}").first.destroy!
        Category.where(name: "{:Name=>\"Masters Women 50+\"}").first.destroy!

        %w{ Road Cyclocross }.each do |name|
          discipline = Discipline.where(name: name).first
          discipline.bar_categories << Category.find_or_create_by_normalized_name("Masters Men 40+")
          discipline.bar_categories << Category.find_or_create_by_normalized_name("Masters Men 50+")
          discipline.bar_categories << Category.find_or_create_by_normalized_name("Masters Men 60+")
          discipline.bar_categories << Category.find_or_create_by_normalized_name("Masters Women 40+")
        
          discipline.bar_categories.delete Category.find_or_create_by_normalized_name("Masters A Men")
          discipline.bar_categories.delete Category.find_or_create_by_normalized_name("Masters B Men")
        end
        
        discipline = Discipline.where(name: "Mountain Bike").first
        discipline.bar_categories << Category.find_or_create_by_normalized_name("Masters Men 50+")
        discipline.bar_categories << Category.find_or_create_by_normalized_name("Masters Women 50+")
        
        Category.cleanup!
      end
    end
  end
end
