class AddCat3ToMtbNovice < ActiveRecord::Migration
  def change
    Race.all.each do |race|
      if race.event.discipline == "Mountain Bike" && race.name["Novice"] && !race.name["Category"]
        name = race.name.gsub("Novice", "Novice (Category 3)")
        puts "#{race.name} => #{name}"
        category = Category.find_or_create_by_normalized_name(name)
        category.parent = race.category.parent
        category.save!
        race.category = category
        race.save!
      end
    end
  end
end
