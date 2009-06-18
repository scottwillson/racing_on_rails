# Year-long best road rider competition for senior & masters men and women in Washington
class WsbaBarr < Competition
  def friendly_name
    'WSBA BARR'
  end
  
  def point_schedule
    [0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16]
  end

  def create_races
    for category_name in [
      'Men Cat 1-2', 'Men Cat 3', 'Men Cat 4-5',
      'Masters Men A', 'Masters Men B', 'Masters Men C', 'Masters Men D', 
      'Masters Women A', 'Masters Women B',
      'Women Cat 1-2', 'Women Cat 3', 'Women Cat 4']

      category = Category.find_or_create_by_name(category_name)
      self.races.create(:category => category)
    end
  end
  
  # source_results must be in person-order
  def source_results(race)
    return [] if source_events(true).empty?
    
    event_ids = source_events.collect do |event|
      event.id
    end
    event_ids = event_ids.join(', ')
    
    results = Result.find_by_sql(
      %Q{ SELECT results.id as id, race_id, person_id, team_id, place, members_only_place
          FROM results  
          LEFT OUTER JOIN races ON races.id = results.race_id 
          LEFT OUTER JOIN categories ON categories.id = races.category_id
          LEFT OUTER JOIN events ON races.event_id = events.id 
            WHERE races.category_id is not null 
              and members_only_place between 1 and 10
              and categories.id in (#{category_ids_for(race)})
              and (results.category_id is null or results.category_id in (#{category_ids_for(race)}))
              and (events.id in (#{event_ids}))
         order by person_id
       }
    )
    results
  end
  
  # per Rob Whitacre
  def place_members_only?
     true
   end
end
