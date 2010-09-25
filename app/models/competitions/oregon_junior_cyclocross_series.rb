class OregonJuniorCyclocrossSeries < Competition
  def friendly_name
    "Oregon Junior Cyclocross Series"
  end
  
  def source_results(race)
    return [] if source_events.empty?
    
    Result.find_by_sql(
      %Q{ SELECT results.* FROM results  
          LEFT JOIN races ON races.id = results.race_id 
          LEFT JOIN categories ON categories.id = races.category_id 
          LEFT JOIN events ON races.event_id = events.id 
          WHERE events.id in (#{source_events.map(&:id)})
            and (place > 0 or place is null or place = '')
            and categories.id in (#{category_ids_for(race)})
            and events.type = "SingleDayEvent"
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

  # By default, does nothing. Useful to apply rule like:
  # * Any results after the first four only get 50-point bonus
  # * Drop lowest-scoring result
  def after_create_competition_results_for(race)
    race.results.each do |result|
      # Don't bother sorting scores unless we need to drop some
      if result.scores.size > 6
        result.scores.sort! { |x, y| y.points <=> x.points }
        lowest_scores = result.scores[6, 2]
        lowest_scores.each do |lowest_score|
          result.scores.destroy(lowest_score)
        end
        # Rails destroys Score in database, but doesn't update the current association
        result.scores(true)
      end
    
      if preliminary?(result)
        result.preliminary = true       
      end    
    end
  end

  def create_races
    [ "Boys 10-12", "Girls 10-12", "Boys 13-14", "Girls 13-14", "Boys 15-16", "Girls 15-16", "Boys 17-18", "Girls 17-18" ].each do |category|
      races.create! :category => Category.find_or_create_by_name(category)
    end
  end

  def minimum_events
    4
  end
  
  def raced_minimum_events?(person, race)
    return true if minimum_events.nil?
    return false if parent.children.empty? || person.nil?

    event_ids = parent.children.collect(&:id).join(", ")
    category_ids = category_ids_for(race)

    count = Result.count_by_sql(
      %Q{ SELECT count(*) FROM results  
          JOIN races ON races.id = results.race_id 
          JOIN categories ON categories.id = races.category_id 
          JOIN events ON races.event_id = events.id 
          WHERE categories.id in (#{category_ids})
              and events.id in (#{event_ids})
              and results.person_id = #{person.id}
       }
    )
    count >= minimum_events
  end

  
  def preliminary?(result)
    minimum_events && parent.children_with_results.size > minimum_events && !parent.completed? && !raced_minimum_events?(result.person, result.race)
  end
end
