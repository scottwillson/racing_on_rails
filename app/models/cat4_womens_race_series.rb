class Cat4WomensRaceSeries < Competition
  has_many :events

  # Expire Cat4WomensRaceSeries web pages from cache. Expires *all* Cat4WomensRaceSeries pages.
  def Cat4WomensRaceSeries.expire_cache
    FileUtils::rm_rf("#{RAILS_ROOT}/public/cat_4_womens_race_series.html")
    FileUtils::rm_rf("#{RAILS_ROOT}/public/cat_4_womens_race_series")
  end

  def friendly_name
    "Cat 4 Womens Race Series"
  end

  def point_schedule
    [ 0, 100, 95, 90, 85, 80, 75, 72, 70, 68, 64, 62, 60, 58, 56 ]
  end

  def source_results(race)
    return [] if events(true).empty?
    
    event_ids = events.collect { |e| e.id }.join(', ')
    
    Result.find_by_sql(
      %Q{ SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
          LEFT OUTER JOIN races ON races.id = results.race_id 
          LEFT OUTER JOIN categories ON categories.id = races.category_id 
          LEFT OUTER JOIN standings ON races.standings_id = standings.id 
          LEFT OUTER JOIN events ON standings.event_id = events.id 
          WHERE place > 0
            and categories.id in (#{category_ids_for(race)})
            and events.id in (#{event_ids})
          order by racer_id
       }
    )
  end

  def points_for(source_result, team_size = nil)
    place = source_result.place.to_i
    if place > 15
      25
    else
      point_schedule[source_result.place.to_i]
    end
  end

  def create_standings
    root_standings = standings.create(:event => self)
    category = Category.find_or_create_by_name('Category 4 Women')
    root_standings.races.create(:category => category)
  end

  def expire_cache
    Cat4WomensRaceSeries.expire_cache
  end
end