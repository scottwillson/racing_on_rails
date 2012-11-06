# Common superclass for Omniums and Series standings.
# Easy to miss override: Overall results only include members
class Overall < Competition
 validates_presence_of :parent
 after_create :add_source_events
 
 def self.parent_event_name
   self.name
 end

  def self.calculate!(year = Time.zone.today.year)
    benchmark(name, :level => :info) {
      transaction do
        parent = ::MultiDayEvent.first(
                        :conditions => ["name = ? and date between ? and ?", parent_event_name, Date.new(year, 1, 1), Date.new(year, 12, 31)])
                        
        if parent && parent.has_results_including_children?(true)
          if parent.overall.nil? || parent.overall.updated_at.nil? || Result.where("updated_at > ?", parent.overall.updated_at).exists?
            unless parent.overall
              # parent.create_overall will create an instance of Overall, which is probably not what we want
              parent.overall = self.new(:parent_id => parent.id)
              parent.overall.save!
            end
            parent.overall.set_date
            parent.overall.destroy_races
            parent.overall.create_races
            parent.overall.calculate!
          end
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
    Overall.benchmark("#{self.class.name} source_results", :level => :debug) {
      results = source_results(race)
    }
    logger.debug("#{self.class.name} Found #{results.size} source results for '#{race.name}'") if logger.debug?
    results
  end

  # source_results must be in person-order
  def source_results(race)
    return [] if parent.children.empty?
    
    event_ids = parent.children.collect do |event|
      event.id
    end
    event_ids = event_ids.join(', ')
    category_ids = category_ids_for(race).join(', ')
    
    Result.find_by_sql(
      %Q{ SELECT results.* FROM results  
          JOIN races ON races.id = results.race_id 
          JOIN categories ON categories.id = races.category_id 
          JOIN events ON races.event_id = events.id 
          WHERE place between 1 and #{point_schedule.size - 1}
              and categories.id in (#{category_ids})
              and events.id in (#{event_ids})
          order by person_id
       }
    )
  end

  # If same rider places twice in same race, only highest result counts
  def create_competition_results_for(results, race)
    competition_result = nil
    results.each_with_index do |source_result, index|
      logger.debug("#{self.class.name} scoring result: #{source_result.date} race: #{source_result.race.name} pl: #{source_result.place} mem pl: #{source_result.members_only_place if place_members_only?} #{source_result.last_name} #{source_result.team_name}") if logger.debug?

      person = source_result.person
      points = points_for(source_result)
      
      # We repeat some calculations here if a person is disallowed
      if points > 0.0 && 
         (!parent.completed? || (parent.completed? && raced_minimum_events?(person, race))) && 
           (!members_only? || member?(person, source_result.date))

        if first_result_for_person?(source_result, competition_result)
          # Intentionally not using results association create method. No need to hang on to all competition results.
          # In fact, this could cause serious memory issues with the Ironman
          competition_result = Result.create!(
             :person => person, 
             :team => (person ? person.team : nil),
             :race => race)
        end

        competition_result.scores.create_if_best_result_for_race(
          :source_result => source_result, 
          :competition_result => competition_result, 
          :points => points
        )
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
  
  # Only members can score points?
  def members_only?
    false 
  end

  def default_bar_points
    0
  end
  
  def minimum_events
    nil
  end
  
  def maximum_events(race)
    6
  end
  
  def raced_minimum_events?(person, race)
    return true if minimum_events.nil?
    return false if parent.children.empty? || person.nil?

    event_ids = parent.children.collect(&:id).join(", ")
    category_ids = category_ids_for(race).join(", ")

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
    minimum_events && 
    parent.children_with_results.size > minimum_events && 
    !parent.completed? && 
    !raced_minimum_events?(result.person, result.race)
  end

  def all_year?
    false
  end
end
