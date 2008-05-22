class TaborSeriesStandings < Standings
  def TaborSeriesStandings.recalculate(year = Date.today.year)
    series = WeeklySeries.find(
              :first, 
              :conditions => ["name = ? and date between ? and ?", "Mt Tabor Series", Date.new(year, 1, 1), Date.new(year, 12, 31)])
    if series && series.has_results?
      standings = TaborSeriesStandings.create!(:name => "Overall", :event => series)
      standings.create_races
      standings.recalculate
    end
  end

  def create_races
    races.create!(:category => Category.find_or_create_by_name('Category 3 Men'))
    races.create!(:category => Category.find_or_create_by_name('Masters Women 35+'))
  end

  # Race#place_results_by_points saves each Result
  def recalculate
    for race in races
      results = source_results_with_benchmark(race)
      create_competition_results_for(results, race)
      after_create_competition_results_for(race)
      race.place_results_by_points(break_ties?)
    end
    save!
  end

  def source_results_with_benchmark(race)
    results = []
    TaborSeriesStandings.benchmark("#{self.class.name} source_results", Logger::DEBUG, false) {
      results = source_results(race)
    }
    logger.debug("#{self.class.name} Found #{results.size} source results for '#{race.name}'") if logger.debug?
    results
  end

  # source_results must be in racer-order
  def source_results(race)
    return [] if event.events.empty?
    
    event_ids = event.events.collect do |event|
      event.id
    end
    event_ids = event_ids.join(', ')    
    
    Result.find_by_sql(
      %Q{ SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
          JOIN races ON races.id = results.race_id 
          JOIN categories ON categories.id = races.category_id 
          JOIN standings ON races.standings_id = standings.id 
          JOIN events ON standings.event_id = events.id 
          WHERE (standings.type = 'TaborSeriesStandings' or standings.type is null)
              and place between 1 and 15
              and categories.id in (#{category_ids_for(race)})
              and events.id in (#{event_ids})
          order by racer_id
       }
    )
  end
  
  # Array of ids (integers)
  # +race+ category, +race+ category's siblings, and any competition categories
  def category_ids_for(race)
    ids = [race.category_id]
    ids = ids + race.category.descendants.map {|category| category.id}
    ids.join(', ')
  end
  
  # If same ride places twice in same race, only highest result counts
  # TODO Replace ifs with methods
  def create_competition_results_for(results, race)
    competition_result = nil
    results.each_with_index do |source_result, index|
      logger.debug("#{self.class.name} scoring result: #{source_result.date} race: #{source_result.race.name} pl: #{source_result.place} mem pl: #{source_result.members_only_place if place_members_only?} #{source_result.last_name} #{source_result.team_name}") if logger.debug?

      racer = source_result.racer
      points = points_for(source_result)
      if points > 0.0 && (!members_only? || member?(racer, source_result.date))
 
        if first_result_for_racer(source_result, competition_result)
          # Intentionally not using results association create method. No need to hang on to all competition results.
          # In fact, this could cause serious memory issues with the Ironman
          competition_result = Result.create!(
             :racer => racer, 
             :team => (racer ? racer.team : nil),
             :race => race)
        end
 
        Competition.benchmark('competition_result.scores.create_if_best_result_for_race') {
          competition_result.scores.create_if_best_result_for_race(
            :source_result => source_result, 
            :competition_result => competition_result, 
            :points => points
          )
        }
      end
      
      # Aggressive memory management. If competition has a race with many results, 
      # the results array can become a large, uneeded, structure
      results[index] = nil
      if index > 0 && index % 1000 == 0
        logger.debug("GC start after record #{index}")
        GC.start
      end
      
    end
  end
  
  # By default, does nothing. Useful to apply rule like:
  # * Any results after the first four only get 50-point bonus
  # * Drop lowest-scoring result
  def after_create_competition_results_for(race)
  end
  
  def break_ties?
    true
  end
  
  # Use the recorded place with all finishers? Or only place with just Assoication member finishers?
  def place_members_only?
    false
  end
  
  def point_schedule
    [0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16, 15, 14, 13, 12, 11]
  end
  
  # Apply points from point_schedule, and split across team
  def points_for(source_result, team_size = nil)
    # TODO Consider indexing place
    # TODO Consider caching/precalculating team size
    team_size = team_size || Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
    if place_members_only?
      points = point_schedule[source_result.members_only_place.to_i].to_f
    else
      points = point_schedule[source_result.place.to_i].to_f
    end
    if points
      points / team_size.to_f
    else
      0
    end
  end
  
  # Only members can score points?
  def members_only?
    false 
  end
  
  def first_result_for_racer(source_result, competition_result)
    competition_result.nil? || source_result.racer != competition_result.racer
  end
end
