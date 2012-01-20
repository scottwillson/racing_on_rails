# Count pre-set list of series source_events + manually-entered non-series events
class Cat4WomensRaceSeries < Competition
  include Concerns::Cat4WomensRaceSeries::Points
  
  def friendly_name
    "Cat 4 Womens Race Series"
  end

  def source_results(race)
    _end_date = RacingAssociation.current.cat4_womens_race_series_end_date || self.end_date
    Result.find_by_sql(
      [%Q{ SELECT results.*
          FROM results  
          LEFT JOIN races ON races.id = results.race_id 
          LEFT JOIN categories ON categories.id = races.category_id 
          LEFT JOIN events ON races.event_id = events.id 
          WHERE (place > 0 or place is null or place = '')
            and categories.id in (?)
            and (events.type = "SingleDayEvent" or events.type is null or events.id in (?))
            and events.ironman is true
            and events.date between ? and ?
          order by person_id
       }, category_ids_for(race), source_events.collect(&:id), date.beginning_of_year, _end_date ]
    )
  end
  
  def participation_points?
    RacingAssociation.current.award_cat4_participation_points?
  end
  
  def association_point_schedule
    RacingAssociation.current.cat4_womens_race_series_points
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
