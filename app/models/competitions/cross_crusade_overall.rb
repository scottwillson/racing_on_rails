# Minimum three-race requirement
# but ... should show not apply until there are at least three races
# TODO Add an Event#overall method
class CrossCrusadeOverall < Overall
  before_create :set_notes
  
  def CrossCrusadeOverall.parent_name
    "Cross Crusade"
  end
  
  def create_races
    races.create!(:category => Category.find_or_create_by_name("Category A"))
    races.create!(:category => Category.find_or_create_by_name("Category B"))
    races.create!(:category => Category.find_or_create_by_name("Category C"))
    races.create!(:category => Category.find_or_create_by_name("Masters 35+ A"))
    races.create!(:category => Category.find_or_create_by_name("Masters 35+ B"))
    races.create!(:category => Category.find_or_create_by_name("Masters 35+ C"))
    races.create!(:category => Category.find_or_create_by_name("Masters 50+"))
    races.create!(:category => Category.find_or_create_by_name("Junior Men"))
    races.create!(:category => Category.find_or_create_by_name("Junior Women"))
    races.create!(:category => Category.find_or_create_by_name("Women A"))
    races.create!(:category => Category.find_or_create_by_name("Women B"))
    races.create!(:category => Category.find_or_create_by_name("Beginner Women"))
    races.create!(:category => Category.find_or_create_by_name("Masters Women 35+"))
    races.create!(:category => Category.find_or_create_by_name("Masters Women 45+"))
    races.create!(:category => Category.find_or_create_by_name("Beginner Men CCX"))
    races.create!(:category => Category.find_or_create_by_name("Singlespeed"))
    races.create!(:category => Category.find_or_create_by_name("Unicycle"))
    races.create!(:category => Category.find_or_create_by_name("Clydesdale"))
  end

  def point_schedule
    [0, 26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
  end

  # Apply points from point_schedule, and split across team
  def points_for(source_result, team_size = nil)
    point_schedule[source_result.place.to_i].to_f
  end

  def minimum_events
    3
  end
  
  def set_notes
    self.notes = %Q{ Three event minimum. Results that don't meet the minimum are listed in italics. See the <a href="http://crosscrusade.com/series.html">series rules</a>. }
  end
end
