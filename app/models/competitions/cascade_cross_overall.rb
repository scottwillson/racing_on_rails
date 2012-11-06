# Minimum two-race requirement
# but ... should show not apply until there are at least two races
class CascadeCrossOverall < Overall  
  def self.parent_event_name
    "Cascade Cross Series"
  end

  def create_races
    races.create!(:category => Category.find_or_create_by_name("Men A"))
    races.create!(:category => Category.find_or_create_by_name("Men B"))
    races.create!(:category => Category.find_or_create_by_name("Men C"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men A 40+"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men B 40+"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men C 40+"))
    races.create!(:category => Category.find_or_create_by_name("Junior A"))
    races.create!(:category => Category.find_or_create_by_name("Junior B"))
    races.create!(:category => Category.find_or_create_by_name("Women A"))
    races.create!(:category => Category.find_or_create_by_name("Women B"))
    races.create!(:category => Category.find_or_create_by_name("Singlespeed"))
  end

  def point_schedule
    [ 0, 26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
  end
  
  def minimum_events
    2
  end
  
  def consider_team_size?
    false
  end

  def consider_points_factor?
    false
  end
end
