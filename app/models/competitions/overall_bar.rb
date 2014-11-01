module Competitions
  # See Bar class.
  class OverallBar < Competition
    # TODO When migrated to Competition::Calculator, need to ensure tied discipline BAR results are not counted as "team" results
    include OverallBars::Categories
    include OverallBars::Points
    include OverallBars::Races
    include OverallBars::Results

    def create_children
      Discipline.find_all_bar.
      reject { |discipline| [Discipline[:age_graded], Discipline[:overall], Discipline[:team]].include?(discipline) }.
      each do |discipline|
        unless Bar.year(year).where(discipline: discipline.name).exists?
          Bar.create!(
            parent: self,
            name: "#{year} #{discipline.name} BAR",
            date: date,
            discipline: discipline.name
          )
        end
      end
    end
    
    def category_names
      [ 
        "Clydesdale",
        "Category 3 Men", 
        "Category 3 Women", 
        "Category 4 Women",
        "Category 4/5 Men",
        "Junior Men", 
        "Junior Women", 
        "Masters Men 4/5", 
        "Masters Men", 
        "Masters Women 4",
        "Masters Women",
        "Senior Men", 
        "Senior Women", 
        "Singlespeed/Fixed", 
        "Tandem"
      ]
    end

    def friendly_name
      'Overall BAR'
    end

    def default_discipline
      "Overall"
    end
  end
end
