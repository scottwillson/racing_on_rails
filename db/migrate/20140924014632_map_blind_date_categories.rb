class MapBlindDateCategories < ActiveRecord::Migration
  def up
    if Competitions::BlindDateAtTheDairyTeamCompetition.count > 0
      men_a = Category.where(name: "Men A").first
      category_a = Category.where(name: "Category A").first
      men_a.parent = category_a
      men_a.save!

      men_b = Category.where(name: "Men B").first
      category_b = Category.where(name: "Category B").first
      men_b.parent = category_b
      men_b.save!

      men_c = Category.where(name: "Men C").first
      category_c = Category.where(name: "Category C").first
      men_c.parent = category_c
      men_c.save!

      parent = Category.where(name: "Masters 35+ B").first
      child = Category.where(name: "Masters Men B 35+").first
      child.parent = parent
      child.save!

      parent = Category.where(name: "Masters 35+ C").first
      child = Category.where(name: "Masters Men C 35+").first
      child.parent = parent
      child.save!

      blind_date_1 = Event.find(22301)

      race = blind_date_1.races.detect { |r| r.name == "Junior Men U14" }
      if race
        race.category_name = "Junior Men 10-13"
        race.save!
      end

      race = blind_date_1.races.detect { |r| r.name == "Junior Men U18" }
      if race
        race.category_name = "Junior Men 14-18"
        race.save!
      end

      race = blind_date_1.races.detect { |r| r.name == "Junior Women U14" }
      if race
        race.category_name = "Junior Women 10-13"
        race.save!
      end

      race = blind_date_1.races.detect { |r| r.name == "Junior Women U18" }
      if race
        race.category_name = "Junior Women 14-18"
        race.save!
      end

      race = blind_date_1.races.detect { |r| r.name == "Masters C 35+" }
      if race
        race.category_name = "Masters Men C 35+"
        race.save!
      end
    end
  end

  def down
    true
  end
end
