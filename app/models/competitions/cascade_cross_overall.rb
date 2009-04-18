# Minimum two-race requirement
# but ... should show not apply until there are at least two races
class CascadeCrossOverall < Overall  
  def CascadeCrossOverall.calculate!(year = Date.today.year)
    source_event = Series.find(
                    :first, 
                    :conditions => ["name = ? and date between ? and ?", "Cascade Cross Series", Date.new(year, 1, 1), Date.new(year, 12, 31)])
    return unless source_event && source_event.has_results?

    unless source_event.overall
      source_event.competitions << self.create!(:name => "Overall")
    end
    
    source_event.overall.destroy_races
    source_event.overall.create_races
    source_event.overall.calculate!
  end

  def create_races
    races.create!(:category => Category.find_or_create_by_name("Men A"))
    races.create!(:category => Category.find_or_create_by_name("Men B"))
    races.create!(:category => Category.find_or_create_by_name("Men C"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men A 40+"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men B 40+"))
    races.create!(:category => Category.find_or_create_by_name("Masters Men C 40+"))
    races.create!(:category => Category.find_or_create_by_name("Junior A"))
    races.create!(:category => Category.find_or_create_by_name("Junior B"))
    races.create!(:category => Category.find_or_create_by_name("Women A"))
    races.create!(:category => Category.find_or_create_by_name("Women B"))
    races.create!(:category => Category.find_or_create_by_name("Singlespeed"))
  end

  # Race#place_results_by_points saves each Result
  def calculate!
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
    CascadeCrossOverall.benchmark("#{self.class.name} source_results", Logger::DEBUG, false) {
      results = source_results(race)
    }
    logger.debug("#{self.class.name} Found #{results.size} source results for '#{race.name}'") if logger.debug?
    results
  end

  # source_results must be in racer-order
  def source_results(race)
    return [] if source_event.children.empty?
    
    event_ids = source_event.children.collect do |event|
      event.id
    end
    event_ids = event_ids.join(', ')
    category_ids = category_ids_for(race)
    
    Result.find_by_sql(
      %Q{ SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
          JOIN races ON races.id = results.race_id 
          JOIN categories ON categories.id = races.category_id 
          JOIN events ON races.event_id = events.id 
          WHERE place between 1 and 18
              and categories.id in (#{category_ids})
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
      
      # We repeat some calculations here if a racer is disallowed
      if points > 0.0 && (!source_event.completed? || (source_event.completed? && raced_minimum_events?(racer, race)))

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
            :points => points)
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
    race.results.each do |result|
      # Don't bother sorting scores unless we need to drop some
      if result.scores.size > 6
        result.scores.sort! { |x, y| x.source_result.place.to_i <=> y.source_result.place.to_i }
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

  def break_ties?
    true
  end

  # Use the recorded place with all finishers? Or only place with just Assoication member finishers?
  def place_members_only?
    false
  end

  def point_schedule
    [0, 26, 20, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
  end

  # Apply points from point_schedule, and split across team
  def points_for(source_result, team_size = nil)
    point_schedule[source_result.place.to_i].to_f
  end

  # Only members can score points?
  def members_only?
    false 
  end

  def first_result_for_racer(source_result, competition_result)
    competition_result.nil? || source_result.racer != competition_result.racer
  end
  
  def minimum_events
    2
  end
  
  def raced_minimum_events?(racer, race)
    return false if source_event.children.empty? || racer.nil?

    event_ids = source_event.children.collect do |event|
      event.id
    end
    event_ids = event_ids.join(', ')
    category_ids = category_ids_for(race)

    count = Result.count_by_sql(
      %Q{ SELECT count(*) FROM results  
          JOIN races ON races.id = results.race_id 
          JOIN categories ON categories.id = races.category_id 
          JOIN events ON races.event_id = events.id 
          WHERE categories.id in (#{category_ids})
              and events.id in (#{event_ids})
              and results.racer_id = #{racer.id}
       }
    )
    count >= minimum_events
  end
  
  def preliminary?(result)
    source_event.children_with_results.size > minimum_events && !source_event.completed? && !raced_minimum_events?(result.racer, result.race)
  end
end
