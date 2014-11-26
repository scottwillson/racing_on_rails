class UpdateMbraBarCategories < ActiveRecord::Migration
  def change
    if RacingAssociation.current.short_name == "MBRA"
      Discipline.transaction do
        %w{ Road Cyclocross }.each do |name|
          discipline = Discipline.where(name: name).first
          discipline.bar_categories << Category.find_or_create_by_normalized_name(name: "Masters Men 40+")
          discipline.bar_categories << Category.find_or_create_by_normalized_name(name: "Masters Men 50+")
          discipline.bar_categories << Category.find_or_create_by_normalized_name(name: "Masters Men 60+")
          discipline.bar_categories << Category.find_or_create_by_normalized_name(name: "Masters Women 40+")
        
          discipline.bar_categories.delete Category.find_or_create_by_normalized_name(name: "Masters A Men")
          discipline.bar_categories.delete Category.find_or_create_by_normalized_name(name: "Masters B Men")
        end
        
        discipline = Discipline.where(name: "Mountain Bike").first
        discipline.bar_categories << Category.find_or_create_by_normalized_name(name: "Masters Men 50+")
        discipline.bar_categories << Category.find_or_create_by_normalized_name(name: "Masters Women 50+")
      end
    end
  end
end
