# Year-long best road rider competition for senior & masters men and women in Washington. WSBA member's only.
class WsbaBarr < Competition
  def friendly_name
    'WSBA BARR'
  end
  
  def point_schedule
    [ 0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16 ]
  end

  def create_races
    for category_name in [
      'Men Cat 1-2', 'Men Cat 3', 'Men Cat 4-5',
      'Masters Men A', 'Masters Men B', 'Masters Men C', 'Masters Men D', 
      'Masters Women A', 'Masters Women B',
      'Women Cat 1-2', 'Women Cat 3', 'Women Cat 4']

      category = Category.find_or_create_by_name(category_name)
      races.create(:category => category)
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
      %Q{ SELECT results.*
          FROM results  
          LEFT OUTER JOIN races ON races.id = results.race_id 
          LEFT OUTER JOIN categories ON categories.id = races.category_id
          LEFT OUTER JOIN events ON races.event_id = events.id 
            WHERE races.category_id is not null 
              and members_only_place between 1 and 10
              and categories.id in (#{category_ids_for(race)})
              and (results.category_id is null or results.category_id in (#{category_ids_for(race)}))
              and (events.id in (#{event_ids}))
              and results.bar
         order by person_id
       }
    )
    results
  end
  
  # Override of base BAR rules, mainly due to TTT rules on dividing points always by 4. Also, no points multiplier
  def points_for(source_result, team_size = nil)
    points = 0
    Bar.benchmark('points_for') {
      results_in_place = Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
      if team_size.nil?
        # assume this is a TTT, score divided by 4 regardless of # of riders
        team_size = (results_in_place > 1) ? 4 : 1 
      end
      points_index = place_members_only? ? source_result.members_only_place.to_i : source_result.place.to_i
      points = point_schedule[points_index].to_f
      points *= points_factor(source_result)
      points /= team_size.to_f 
    }
    points
  end
  
  def place_members_only?
     true
   end
end
