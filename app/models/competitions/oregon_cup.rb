# Year-long best rider competition for senior men and women
class OregonCup < Competition
  # TODO Initialize OregonCup with "today" attribute
  def friendly_name
    'Oregon Cup'
  end
  
  def point_schedule
    [0, 100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10]
  end

  # source_results must be in racer-order
  def source_results(race)
    return [] if source_events(true).empty?
    
    event_ids = source_events.collect do |event|
      event.id
    end
    event_ids = event_ids.join(', ')    
    
    results = Result.find_by_sql(
      %Q{SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
          LEFT OUTER JOIN races ON races.id = results.race_id 
          LEFT OUTER JOIN categories ON categories.id = races.category_id
          LEFT OUTER JOIN events ON races.event_id = events.id 
            WHERE races.category_id is not null 
              and place between 1 and 20
              and categories.id in (#{category_ids_for(race)})
              and (results.category_id is null or results.category_id in (#{category_ids_for(race)}))
              and events.id in (#{event_ids})
         order by racer_id
       }
    )
    remove_duplicate_results(results)
    results
  end
  
  def remove_duplicate_results(results)
    results.delete_if do |result|
      results.any? do |other_result|
        result.event == other_result.event && 
        !result.race.notes["Oregon Cup"] &&
        other_result.race.notes["Oregon Cup"]
      end
    end
  end
  
  def create_races
    category = Category.find_or_create_by_name('Senior Men')
    self.races.create(:category => category)

    category = Category.find_or_create_by_name('Senior Women')
    self.races.create(:category => category)
  end
  
  def latest_event_with_results
    for event in source_events.sort_by(&:date)
      for race in event.races
        if !race.results.empty?
          return event
        end
      end
    end
    nil
  end
  
  def more_events?(today = Date.today)
    !self.next_event(today).nil?
  end
  
  # FIXME: Needs to sort by date?
  def next_event(today = Date.today)
    for event in source_events.sort_by(&:date)
      if event.date > today
        return event
      end
    end
    nil
  end
end
