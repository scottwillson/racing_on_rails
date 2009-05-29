# Easy to miss override: Overall results only include members
class Overall < Competition
 validates_presence_of :parent
 after_create :add_source_events
 
  def Overall.calculate!(year = Date.today.year)
    benchmark("#{name} calculate!", Logger::INFO, false) {
      transaction do
        parent = MultiDayEvent.find(
                        :first, 
                        :conditions => ["name = ? and date between ? and ?", parent_name, Date.new(year, 1, 1), Date.new(year, 12, 31)])
                        
        if parent && parent.has_results_including_children?(true)
          unless parent.overall
            # parent.create_overall will create an instance of Overall, which is probably not what we want
            parent.overall = self.new(:parent_id => parent.id)
            parent.overall.save!
          end
          parent.overall.destroy_races
          parent.overall.create_races
          parent.overall.calculate!
        end
      end
    }
    true
  end

  def add_source_events
    parent.children.each do |source_event|
      source_events << source_event
    end
  end

  def source_results_with_benchmark(race)
    results = []
    Overall.benchmark("#{self.class.name} source_results", Logger::DEBUG, false) {
      results = source_results(race)
    }
    logger.debug("#{self.class.name} Found #{results.size} source results for '#{race.name}'") if logger.debug?
    results
  end

  # source_results must be in racer-order
  def source_results(race)
    return [] if parent.children.empty?
    
    event_ids = parent.children.collect do |event|
      event.id
    end
    event_ids = event_ids.join(', ')
    category_ids = category_ids_for(race)
    
    Result.find_by_sql(
      %Q{ SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
          JOIN races ON races.id = results.race_id 
          JOIN categories ON categories.id = races.category_id 
          JOIN events ON races.event_id = events.id 
          WHERE place between 1 and #{point_schedule.size - 1}
              and categories.id in (#{category_ids})
              and events.id in (#{event_ids})
          order by racer_id
       }
    )
  end

  # If same rider places twice in same race, only highest result counts
  # TODO Replace ifs with methods
  def create_competition_results_for(results, race)
    competition_result = nil
    results.each_with_index do |source_result, index|
      logger.debug("#{self.class.name} scoring result: #{source_result.date} race: #{source_result.race.name} pl: #{source_result.place} mem pl: #{source_result.members_only_place if place_members_only?} #{source_result.last_name} #{source_result.team_name}") if logger.debug?

      racer = source_result.racer
      points = points_for(source_result)
      
      # We repeat some calculations here if a racer is disallowed
      if points > 0.0 && 
         (!parent.completed? || (parent.completed? && raced_minimum_events?(racer, race))) && 
           (!members_only? || member?(racer, source_result.date))

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
  
  # Only members can score points?
  def members_only?
    false 
  end
  
  def minimum_events
    nil
  end
  
  def raced_minimum_events?(racer, race)
    return true if minimum_events.nil?
    return false if parent.children.empty? || racer.nil?

    event_ids = parent.children.collect(&:id).join(", ")
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
    minimum_events && parent.children_with_results.size > minimum_events && !parent.completed? && !raced_minimum_events?(result.racer, result.race)
  end
end
