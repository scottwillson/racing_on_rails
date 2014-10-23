# Beginner Men
# Beginner Women
# Clydesdale
# Junior Men
# Junior Women
# Masters Men
# Masters Women
# Men A
# Men B
# Men C
# Singlespeed/Fixed
# Women A
# Women B
# Women C

class FixObraCyclocrossBarCategories < ActiveRecord::Migration
  def change
    if RacingAssociation.current.short_name == "OBRA"
      Category.transaction do
        # Blind Date overall
        Event.where(id: [ 22296, 23699 ]).update_all(bar_points: 0)
        
        {
          "Junior Men" => [
            "Junior - Boys 10-14",
            "Junior B/C U14",
            "Junior Men 10-12",
            "Junior Men 10-13",
            "Junior Men 13-14",
            "Junior Men 14-18",
            "Junior Men 15-16",
            "Junior Men 17-18",
            "Junior Men C U14",
            "Junior Men U18 A/B",
            "Junior Men U18 B/C"
          ],
          "Junior Women" => [
            "Junior Women 10-12",
            "Junior Women 10-13",
            "Junior Women 14-18",
            "Junior Women 15-16",
            "Junior Women 17-18",
            "Junior Women C U14"
          ],
          "Masters Men" => [
            "Masters 50+ Men",
            "Masters A/B 35+",
            "Masters A/B 35-49",
            "Masters Men 35+ A",
            "Masters Men 35+ B",
            "Masters Men 35+ C",
            "Masters Men 50+",
            "Masters Men 60+",
            "Masters Men A 40+",
            "Masters Men A/B 50+",
            "Masters Men B 35+",
            "Masters Men B/C 35+",
            "Masters Men B/C 35-49",
            "Masters Men B/C 50+",
            "Masters Men C 35+",
            "Masters Men C 50+", 
            "Category A/B - Men 40+",
            "Category B/C - Men 40+",
            "Category C - Men 40+"
          ],
          "Masters Women" => [
            "Masters 50+ Women",
            "Masters Women 35+ A",
            "Masters Women 35+ B",
            "Masters Women 45+",
            "Masters Women B 50+",
            "Masters Women B/C 35+",
            "Masters Women B/C 50+",
            "Masters Women C 35+",
            "Masters Women C 50+",
            "Category B/C - Women 40+",
            "Women B/C 35+"
          ],
          "Men A" => [
            "Category A",
            "Category A Men",
            "Category A/B - Men",
            "Men Category A",
            "Men Category A/B",
            "Senior Men Category A/B",
            "Category A - Men"
          ],
          "Men B" => [
            "Category B",
            "Category B Men",
            "Category B/C - Men",
            "Men Category B",
            "Senior Men B/C",
            "Senior Men Category B/C"
          ],
          "Men C" => [
            "Category C",
            "Category C - Men",
            "Category C Men",
            "Men Category C"
          ],
          "Singlespeed/Fixed" => [
            "Singlespeed",
            "Singlespeed Men",
            "Singlespeed Women"
          ],
          "Women A" => [
            "Category A Women",
            "Category A/B - Women",
            "Senior Women A/B",
            "Senior Women Category A/B",
            "Women Category A"
          ],
          "Women B" => [
            "Category B Women",
            "Category B/C - Women",
            "Senior Women B/C",
            "Women B/C",
            "Women Category B"
          ],
          "Women C" => [
            "Category C - Women",
            "Category C Women",
            "Women Category C"
          ]
        }.each do |parent, children|
          parent = Category.where(name: parent).first
          children.each do |child|
            child = Category.where(name: child).first
            if !child.ancestors.include?(parent)
              puts "#{child.name} not a child of #{parent.name}: #{child.ancestors.map(&:name).join(', ')}"
              child.parent = parent
              child.save!
            end
          end
        end
      end
    end
  end
end
