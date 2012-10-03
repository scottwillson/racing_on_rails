class OregonJuniorCyclocrossSeries < Competition
  def friendly_name
    "Junior Cyclocross Series"
  end
  
  def source_results(race)
    return [] if source_events.empty?
    
    Result.find_by_sql(
      %Q{ SELECT results.* FROM results  
          LEFT JOIN races ON races.id = results.race_id 
          LEFT JOIN categories ON categories.id = races.category_id 
          LEFT JOIN events ON races.event_id = events.id 
          WHERE events.id in (#{source_events.map(&:id).join(",")})
            and (place > 0 or place is null or place = '')
            and categories.id in (#{category_ids_for(race).join(",")})
            and (events.type = "SingleDayEvent" or events.type = "Event")
            and events.date between '#{year}-01-01' and '#{year}-12-31'
          order by person_id
       }
    )
  end

  def point_schedule
    [ 0, 30, 28, 26, 24, 22, 20, 18, 17, 16, 15, 14, 13, 12, 11, 10 ]
  end

  def members_only?
    false
  end

  def create_races
    races.create! :category => Category.find_or_create_by_name("Junior Men 10-12")
    races.create! :category => Category.find_or_create_by_name("Junior Men 13-14")
    races.create! :category => Category.find_or_create_by_name("Junior Men 15-16")
    races.create! :category => Category.find_or_create_by_name("Junior Men 17-18")
    races.create! :category => Category.find_or_create_by_name("Junior Women 11-12")
    races.create! :category => Category.find_or_create_by_name("Junior Women 13-14")
    races.create! :category => Category.find_or_create_by_name("Junior Women 15-16")
    races.create! :category => Category.find_or_create_by_name("Junior Women 17-18")
  end

  def maximum_events(race)
    6
  end
  
  def double_points_for_last_event?
    false
  end
  
  def default_bar_points
    0
  end
  
  def all_year
    false
  end
end
