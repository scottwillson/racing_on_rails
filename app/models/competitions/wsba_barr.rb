# Year-long best road rider competition for senior & masters men and women in Washington
class WsbaBarr < Competition
  def friendly_name
    'WSBA BARR'
  end
  
  def point_schedule
    [0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16]
  end

  def create_races
    races.create!(:category => Category.find_or_create_by_name("Men Cat 1-2"))
    races.create!(:category => Category.find_or_create_by_name("Men Cat 3"))
    races.create!(:category => Category.find_or_create_by_name("Men Cat 4-5"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men A"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men B"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men C"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men D"))
    races.create!(:category => Category.find_or_create_by_name("Masters Women A"))
    races.create!(:category => Category.find_or_create_by_name("Masters Women B"))
    races.create!(:category => Category.find_or_create_by_name("Women Cat 1-2"))
    races.create!(:category => Category.find_or_create_by_name("Women Cat 3"))
    races.create!(:category => Category.find_or_create_by_name("Women Cat 4"))
  end
end
