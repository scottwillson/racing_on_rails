# Year-long best rider competition for senior men and women. http://obra.org/oregon_cup
class OregonCup < Competition
  def friendly_name
    'Oregon Cup'
  end
  
  def point_schedule
    [ 0, 100, 75, 60, 50, 45, 40, 35, 30, 25, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10 ]
  end

  # source_results must be in person-order
  def source_results(race)
    return [] if source_events(true).empty?
    
    event_ids = source_events.collect do |event|
      event.id
    end
    event_ids = event_ids.join(', ')
    
    results = Result.find_by_sql(
      %Q{SELECT results.id as id, race_id, person_id, results.team_id, place FROM results  
          LEFT OUTER JOIN races ON races.id = results.race_id 
          LEFT OUTER JOIN categories ON categories.id = races.category_id
          LEFT OUTER JOIN events ON races.event_id = events.id 
            WHERE races.category_id is not null 
              and place between 1 and 20
              and categories.id in (#{category_ids_for(race)})
              and (results.category_id is null or results.category_id in (#{category_ids_for(race)}))
              and (events.id in (#{event_ids}) or events.parent_id in (#{event_ids}))
         order by person_id
       }
    )
    remove_duplicate_results(results)
    results
  end
  
  # Women are often raced together and then scored separately. Combined Women 1/2/3 results count for Oregon Cup.
  # Mark Oregon Cup race by adding "Oregon Cup" to event name, race name, event notes, or race notes.
  def remove_duplicate_results(results)
    results.delete_if do |result|
      results.any? do |other_result|
        result != other_result &&
        result.race != other_result.race &&
        result.event.root == other_result.event.root &&
        (
          other_result.race.notes.include?("Oregon Cup") ||
          ((result.event.root != other_result.event.root) &&
            (other_result.event.notes.include?("Oregon Cup") || other_result.event.name.include?("Oregon Cup")))
        )
      end
    end
  end

  def category_ids_for(race)
    ids = [race.category_id]
    ids = ids + race.category.descendants.map(&:id)
    if race.category == Category.find_or_create_by_name('Senior Women')
      cat_3_women = Category.find_or_create_by_name('Category 3 Women')
      ids = ids + [cat_3_women.id]
      ids = ids + cat_3_women.descendants.map(&:id)
    end
    ids.join(', ')
  end
  
  def create_races
    category = Category.find_or_create_by_name('Senior Men')
    races.create :category => category

    category = Category.find_or_create_by_name('Senior Women')
    races.create :category => category
  end
  
  def latest_event_with_results
    source_events.sort_by(&:date).each do |event|
      event.races.each do |race|
        if race.results.any?
          return event
        end
      end
    end
    nil
  end
  
  # Unreliable
  def more_events?(today = Date.today)
    !self.next_event(today).nil?
  end
  
  # Unreliable
  def next_event(today = Date.today)
    for event in source_events.sort_by(&:date)
      if event.date > today
        return event
      end
    end
    nil
  end
end
