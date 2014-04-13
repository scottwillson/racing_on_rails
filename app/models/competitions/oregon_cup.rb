# Year-long best rider competition for senior men. http://obra.org/oregon_cup
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
      %Q{SELECT results.* FROM results
          LEFT OUTER JOIN races ON races.id = results.race_id
          LEFT OUTER JOIN categories ON categories.id = races.category_id
          LEFT OUTER JOIN events ON races.event_id = events.id
            WHERE races.category_id is not null
              and events.type = 'SingleDayEvent'
              and place between 1 and 20
              and categories.id in (#{category_ids_for(race).join(", ")})
              and (results.category_id is null or results.category_id in (#{category_ids_for(race).join(", ")}))
              and (events.id in (#{event_ids}) or events.parent_id in (#{event_ids}))
         order by person_id
       }
    )
    remove_duplicate_results results
    results
  end

  # Women are often raced together and then scored separately. Combined Women 1/2/3 results count for Oregon Cup.
  # Mark Oregon Cup race by adding "Oregon Cup" to event name, race name, event notes, or race notes.
  def remove_duplicate_results(results)
    results.delete_if do |result|
      results.any? do |other_result|
        result != other_result &&
        result.race_id != other_result.race_id &&
        result.event.root == other_result.event.root &&
        (
          other_result.race.notes.include?("Oregon Cup") ||
          other_result.event.notes.include?("Oregon Cup") ||
          other_result.event.name.include?("Oregon Cup")
        )
      end
    end
  end

  def create_races
    category = Category.find_or_create_by(:name => "Senior Men")
    races.create :category => category
  end

  def all_year?
    false
  end
end
