class CrossCrusadeCallups < Competition
  default_value_for :name, "Cross Crusade Call-ups"

  def create_races
    races.create!(:category => Category.find_or_create_by(:name => "Category A"))
    races.create!(:category => Category.find_or_create_by(:name => "Category B"))
    races.create!(:category => Category.find_or_create_by(:name => "Category C"))
    races.create!(:category => Category.find_or_create_by(:name => "Masters 35+ A"))
    races.create!(:category => Category.find_or_create_by(:name => "Masters 35+ B"))
    races.create!(:category => Category.find_or_create_by(:name => "Masters 35+ C"))
    races.create!(:category => Category.find_or_create_by(:name => "Masters 50+"))
    races.create!(:category => Category.find_or_create_by(:name => "Masters 60+"))
    races.create!(:category => Category.find_or_create_by(:name => "Junior Men"))
    races.create!(:category => Category.find_or_create_by(:name => "Junior Women"))
    races.create!(:category => Category.find_or_create_by(:name => "Women A"))
    races.create!(:category => Category.find_or_create_by(:name => "Women B"))
    races.create!(:category => Category.find_or_create_by(:name => "Women C"))
    races.create!(:category => Category.find_or_create_by(:name => "Masters Women 35+ A"))
    races.create!(:category => Category.find_or_create_by(:name => "Masters Women 35+ B"))
    races.create!(:category => Category.find_or_create_by(:name => "Masters Women 45+"))
    races.create!(:category => Category.find_or_create_by(:name => "Singlespeed"))
    races.create!(:category => Category.find_or_create_by(:name => "Unicycle"))
    races.create!(:category => Category.find_or_create_by(:name => "Clydesdale"))
  end

  def source_results(race)
    event_ids = source_events.map(&:id).join(", ")
    category_ids = category_ids_for(race).join(", ")

    Result.find_by_sql(
      %Q{ SELECT results.* FROM results
          JOIN races ON races.id = results.race_id
          JOIN categories ON categories.id = races.category_id
          JOIN events ON races.event_id = events.id
          WHERE place between 1 and #{point_schedule.size - 1}
              and categories.id in (#{category_ids})
              and events.id in (#{event_ids})
          order by person_id
       }
    )
  end

  def point_schedule
    [ 0, 15, 12, 10, 8, 7, 6, 5, 4, 3, 2 ]
  end

  # Apply points from point_schedule, and split across team
  def points_for(source_result, team_size = nil)
    point_schedule[source_result.place.to_i].to_f
  end

  def all_year?
    false
  end
end
