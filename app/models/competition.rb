# Year-long competition that derive there standings from other Events:
# BAR, Ironman
class Competition < Event
  has_many :competition_categories do
    def create_unless_exists(attributes)
      if attributes[:source_category]
        existing = find(:first, :conditions => ['competition_id = ? and category_id = ? and source_category_id = ?', 
                          @owner.id, attributes[:category].id, attributes[:source_category].id])
      else
        existing = find(:first, :conditions => ['competition_id = ? and category_id = ?', 
                          @owner.id, attributes[:category].id])
      end
      return existing unless existing.nil?
      create(attributes)
    end
  end
  
  # TODO Validate dates
  # TODO Use class methods to set things like friendly_name
  
  after_create  :create_standings
  after_save    :expire_cache
  
  # Calculate clashes with internal Rails method
  # Destroys existing BAR for the year first.
  # TODO store in database?
  def Competition.recalculate(year = Date.today.year)
    # TODO: Use FKs in database to cascade delete`
    # TODO Use Hashs or class instead of iterating through Arrays!
    benchmark = Benchmark.measure {
      transaction do
        # TODO move to superclass
        year = year.to_i if year.is_a?(String)
        date = Date.new(year, 1, 1)
        competition = find_or_create_by_date(date)
        raise competition.errors.full_messages unless competition.errors.empty?
        competition.destroy_standings
        competition.create_standings
        competition.recalculate
      end
    }
    logger.info("#{self.class.name} #{benchmark}")
    # Don't return the entire populated instance!
    true
  end
  
  def initialize(attributes = nil)
    super
    if self.date.month != 1 or self.date.day != 1
      self.date = Date.new(Date.today.year)    
    end
  end

  def friendly_name
    'Competition'
  end
  
  # Same as +date+. Should always be January 1st
  def start_date
    date
  end
  
  # Last day of year for +date+
  def end_date
    Date.new(date.year, 12, 31)
  end
  
  # Assert start and end dates are first and last days of the year
  def valid_dates
    if !start_date or start_date.month != 1 or start_date.day != 1
      errors.add("start_date", "Start date must be January 1st")
    end
    if !end_date or end_date.month != 12 or end_date.day != 31
      errors.add("end_date", "End date must be December 31st")
    end
  end

  def destroy_standings
    for s in standings(true)
      s.destroy
    end
  end
  
  def name
    self[:name] || "#{date.year} #{friendly_name}"
  end
  
  def create_standings
    new_standings = standings.create
    category = Category.find_or_create_by_name(self.class.name.demodulize)
    new_standings.races.create(:category => category)
    new_standings
  end

  def recalculate
    disable_notification!
    for individual_standings in standings(true)
      for race in individual_standings.races
        logger.debug("#{self.class.name} Find source results for '#{race.name}'") if logger.debug?
        results = source_results(race)
        logger.debug("#{self.class.name} Found #{results.size} source results") if logger.debug?
      
        create_competition_results_for(results, race)
        place_results_by_points
      end
    end
    
    save!
    enable_notification!
  end
  
  def point_schedule
    []
  end
  
  # source_results must be in racer, place ascending order
  def source_results(race)
    []
  end
  
  # Array of ids (integers)
  # +race+ category, +race+ category's siblings, and any competition categories
  def category_ids_for(race)
    ids = [race.category_id]
    ids = ids + race.category.children.map {|category| category.id}
    ids.join(', ')
  end
  
  # If same ride places twice in same race, only highest result counts
  # TODO Replace ifs with methods
  def create_competition_results_for(results, race)
    competition_result = nil
    for source_result in results
      logger.debug("#{self.class.name} scoring result: #{source_result.race.name} #{source_result.place} #{source_result.last_name} #{source_result.team_name}") if logger.debug?

      racer = source_result.racer
      if member?(racer, source_result.race.standings.date)

        if first_result_for_racer(source_result, competition_result)
          competition_result = race.results.create(:racer => racer)
        end

        competition_result.scores.create_if_best_result_for_race(
          :source_result => source_result, 
          :competition_result => competition_result, 
          :points => points_for(source_result)
        )
        # TODO Need to do this every time? Maybe before save?
        competition_result.calculate_points
      end
    end
  end
  
  def place_results_by_points
    for s in standings
      s.place_results_by_points(break_ties?)
    end
  end
  
  def break_ties?
    true
  end
  
  def member?(racer, date)
    racer && racer.member?(date)
  end
  
  def first_result_for_racer(source_result, competition_result)
    competition_result.nil? || source_result.racer != competition_result.racer
  end
  
  # Apply points from @point_schedule, and adjust for team size
  def points_for(source_result)
    team_size = Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
    points_schedule[source_result.place.to_i] * source_result.race.bar_points / team_size
  end

  def expire_cache
  end
  
  def inspect
    standings.each {|s|
      puts(self.class.name)
      puts("#{self.class.name} #{s.name}")
      s.races.each {|r| 
        puts(self.class.name)
        puts("#{self.class.name}   #{r.name}")
        r.results.sort.each {|result|
          puts("#{self.class.name}      #{result.to_long_s}")
          result.scores.each{|score|
            puts("#{self.class.name}         #{score.source_result.place} #{score.source_result.race.standings.name}  #{score.source_result.race.name} #{score.points}")
          }
        }
      }
    }
    true
  end

  def to_s
    "<self.class #{id} #{name} #{start_date} #{end_date}>"
  end
end
