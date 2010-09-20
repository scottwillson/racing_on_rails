# Count pre-set list of series source_events + manually-entered non-series events
class Cat4WomensRaceSeries < Competition
  def friendly_name
    "Cat 4 Womens Race Series"
  end

  def point_schedule
    if RacingAssociation.current.cat4_womens_race_series_points.empty?
      [ 0, 100, 95, 90, 85, 80, 75, 72, 70, 68, 66, 64, 62, 60, 58, 56 ]
    else
      RacingAssociation.current.cat4_womens_race_series_points
    end
  end

  def source_results(race)
    end_date = RacingAssociation.current.cat4_womens_race_series_end_date || Time.zone.now.end_of_year.to_date
    Result.find_by_sql(
      [%Q{ SELECT results.id as id, race_id, person_id, results.team_id, place
          FROM results  
          LEFT JOIN races ON races.id = results.race_id 
          LEFT JOIN categories ON categories.id = races.category_id 
          LEFT JOIN events ON races.event_id = events.id 
          WHERE (place > 0 or place is null or place = '')
            and categories.id in (#{category_ids_for(race)})
            and (events.type = "SingleDayEvent" or events.type is null or events.id in (?))
            and events.ironman is true
            and events.date between '#{year}-01-01' and '#{end_date.to_s(:db)}'
          order by person_id
       }, source_events.collect(&:id) ]
    )
  end

  def points_for(source_result, team_size = nil)
    if RacingAssociation.current.award_cat4_participation_points?
      # If it's a finish without a number, it's always 15 points
      return 15 if source_result.place.blank?
    
      event_ids = source_events.collect(&:id)
      place = source_result.place.to_i

      if event_ids.include?(source_result.event_id) || 
         (source_result.event.parent_id && 
          event_ids.include?(source_result.event.parent_id) && 
          source_result.event.parent.races.none? { |race| cat_4_categories.include?(race.category) })
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
      event_ids = source_events.collect(&:id)
      place = source_result.place.to_i

      if (event_ids.include?(source_result.event_id) || 
          (source_result.event.parent_id && event_ids.include?(source_result.event.parent_id) && source_result.event.parent.races.none?)) &&
           place < point_schedule.size
        return point_schedule[source_result.place.to_i] || 0
      end
    end

    0
  end

  def members_only?
    false
  end

  def create_races
    races.create :category => category
  end
  
  def cat_4_categories
    [ category ] + category.descendants
  end
  
  def category
    @category ||= RacingAssociation.current.cat4_womens_race_series_category || Category.find_or_create_by_name("Women Cat 4")
  end
end
