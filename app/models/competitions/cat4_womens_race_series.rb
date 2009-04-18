class Cat4WomensRaceSeries < Competition
  # Expire Cat4WomensRaceSeries web pages from cache. Expires *all* Cat4WomensRaceSeries pages.
  def Cat4WomensRaceSeries.expire_cache
    FileUtils::rm_rf("#{RAILS_ROOT}/public/cat4_womens_race_series.html")
    FileUtils::rm_rf("#{RAILS_ROOT}/public/cat4_womens_race_series")
  end

  def friendly_name
    "Cat 4 Womens Race Series"
  end

  def point_schedule
    ASSOCIATION.cat4_womens_race_series_points || [ 0, 100, 95, 90, 85, 80, 75, 72, 70, 68, 66, 64, 62, 60, 58, 56 ]
  end

  def source_results(race)
    Result.find_by_sql(
      %Q{ SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
          LEFT JOIN races ON races.id = results.race_id 
          LEFT JOIN categories ON categories.id = races.category_id 
          LEFT JOIN events ON races.event_id = events.id 
          WHERE (place > 0 or place is null or place = '')
            and categories.id in (#{category_ids_for(race)})
            and events.type = "SingleDayEvent"
            and events.date between '#{year}-01-01' and '#{year}-12-31'
          order by racer_id
       }
    )
  end

  def points_for(source_result, team_size = nil)
    if ASSOCIATION.award_cat4_participation_points?
      # If it's a finish without a number, it's always 15 points
      return 15 if source_result.place.blank?
    
      event_ids = source_events.collect { |e| e.id }
      place = source_result.place.to_i

      if event_ids.include?(source_result.event_id)
        if place >= point_schedule.size
          return 25
        else
          return point_schedule[source_result.place.to_i] || 0
        end
      elsif place > 0
        return 15
      end
    else
      return 0 if source_result.place.blank?
      event_ids = source_events.collect { |e| e.id }
      place = source_result.place.to_i

      if event_ids.include?(source_result.event_id) && place < point_schedule.size
        return point_schedule[source_result.place.to_i] || 0
      end
    end

    0
  end

  def members_only?
    false
  end

  def create_races
    category = Category.find_or_create_by_name(ASSOCIATION.cat4_womens_race_series_category || "Women Cat 4")
    self.races.create(:category => category)
  end

  def expire_cache
    Cat4WomensRaceSeries.expire_cache
  end
end
