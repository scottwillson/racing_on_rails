class Bar < Competition

  # TODO Add add_child(...) to Race
  
  validate :valid_dates
  
  POINT_SCHEDULE = [0, 30, 25, 22, 19, 17, 15, 13, 11, 9, 7, 5, 4, 3, 2, 1] unless defined?(POINT_SCHEDULE)
  POINTS_AND_LABELS = [['None', 0], ['Normal', 1], ['Double', 2], ['Triple', 3]]

  # Calculate clashs with internal Rails method
  def Bar.recalculate(year = Date.today.year, progress_monitor = NullProgressMonitor.new)
    # TODO: Use FKs in database to cascade delete`
    # TODO Use Hashs or class instead of iterating through Arrays!
    progress_monitor.text = "#{year} BAR"
    progress_monitor.total = 40
    benchmark = Benchmark.measure {
      Bar.transaction do
        # TODO move to superclass
        year = year.to_i if year.is_a?(String)
        progress_monitor.detail_text = "Destroy existing standings"
        existing_bar = Bar.find_by_date("#{year}-01-01")
        if (existing_bar)
          existing_bar.destroy_standings
          existing_bar.destroy
        end
    
        progress_monitor.increment(1)
        progress_monitor.detail_text = "Create new standings"
        bar = new_yearly_standings(year)
        bar.disable_notification!
        
        # Qualifying = counts towards the BAR "race" and BAR results
        # Example: Piece of Cake RR, 6th, Jon Knowlson
        #
        # bar_result, bar_race = BAR itself and placing in the BAR
        # Example: Senior Men BAR, 130th, Jon Knowlson, 45 points
        #
        # BAR results add scoring results as scores
        # Example: 
        # Senior Men BAR, 130th, Jon Knowlson, 18 points
        #  - Piece of Cake RR, 6th, Jon Knowlson 10 points
        #  - Silverton RR, 8th, Jon Knowlson 8 points
        for discipline in Discipline.find_all_bar
          progress_monitor.increment(1)
          progress_monitor.detail_text = "Find #{discipline.name} results"
          RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR Finding results for #{discipline.name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
          # Other operation rely on sort order. Simple numeric sort OK because only 1-15 count for BAR
          scoring_results = Result.find_by_sql(
            %Q{SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
                LEFT OUTER JOIN races ON races.id = results.race_id 
                LEFT OUTER JOIN standings ON races.standings_id = standings.id 
                LEFT OUTER JOIN events ON standings.event_id = events.id 
                  WHERE (races.category_id is not null 
                    and place in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15) 
                    and (standings.discipline = '#{discipline.name}' or (standings.discipline is null and events.discipline = '#{discipline.name}'))
                    and events.type = 'SingleDayEvent' 
                    and (races.bar_points > 0 or (races.bar_points is null and standings.bar_points > 0))
                    and standings.date >= '#{year}-01-01' 
                    and standings.date <= '#{year}-12-31') 
                order by results.place asc}
          )
          RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR Found #{scoring_results.size} scoring results") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
          
          # Create BAR discipline results for each scoring race result
          scoring_results = racers_best_result_for_each_race(scoring_results)
          for scoring_result in scoring_results
            RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR #{discipline.name} scoring result: #{scoring_result.race.name} #{scoring_result.place} #{scoring_result.last_name} #{scoring_result.team_name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
            racer = scoring_result.racer
            team = scoring_result.team
            races = bar.find_races(scoring_result)
            if races and racer and racer.member
              for race in races
                bar_result = race.results.detect {|result| result.racer == racer}
                if bar_result.nil?
                  bar_result = race.results.create
                  raise(RuntimeError, bar_result.errors.full_messages) unless bar_result.errors.empty?
                  bar_result.racer = racer
                  bar_result.team = team
                  RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR Add new BAR result to #{race.name} for #{racer.last_name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
                else
                  RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR Existing BAR result. #{bar_result.racer.last_name} == #{racer.last_name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
                end
                score = bar_result.scores.create(
                  :source_result => scoring_result, 
                  :competition_result => bar_result, 
                  :points => points_for(scoring_result)
                )
                raise(RuntimeError, score.errors.full_messages) unless score.errors.empty?
                bar_result.calculate_points
              end
            end
            # TODO Move static methods to instance
            create_team_result(scoring_result, bar)
          end
        end
        
        # Sort discipline BAR results and assign places
        for standings in bar.standings
          progress_monitor.increment(1)
          for race in standings.races
            progress_monitor.detail_text = "Sort #{standings.name} #{race.name}"
            race.results.sort! {|x,y| y.points <=> x.points }
            progress_monitor.detail_text = "Save #{standings.name} #{race.name}"
            place = 1
            for result in race.results
              result.update_attribute(:place, place)
              place = place + 1
            end
          end
        end
    
        # Create overall BAR results based on discipline results
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR Save all discipline standings") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
        # overall BAR: Add results from discipline BAR races
        overall_standings = bar.standings.detect{|standings| standings.name == "Overall" }
        for bar_standings in bar.standings
          if bar_standings.name != "Overall" and bar_standings.name != 'Team'
            for discipline_race in bar_standings.races
              for discipline_source_result in discipline_race.results.sort!
                RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR Overall scoring result: '#{discipline_source_result.race.standings.name}' #{discipline_source_result.race.category} #{discipline_source_result.place} #{discipline_source_result.last_name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
                if discipline_source_result.race.category and discipline_source_result.race.category.overall
                  racer = discipline_source_result.racer
                  progress_monitor.detail_text = "#{racer.first_name} #{racer.last_name}"
                  bar_race = bar.find_overall_race(discipline_source_result)
                  overall_bar_result = bar_race.results.detect {|result| result.racer == racer}
                  if overall_bar_result.nil?
                    overall_bar_result = bar_race.results.create
                    raise(RuntimeError, overall_bar_result.errors.full_messages) unless overall_bar_result.errors.empty?
                    overall_bar_result.racer = racer
                    overall_bar_result.team = discipline_source_result.team
                    RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR Add new BAR result to #{bar_race.name} for #{racer.last_name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
                    overall_bar_result.save!
                  else
                    RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR Existing BAR result. #{overall_bar_result.last_name} == #{racer.last_name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
                  end
                  overall_bar_result.scores.create(
                    :source_result => discipline_source_result, 
                    :competition_result => overall_bar_result, 
                    :points => overall_points_for(discipline_source_result))
                  raise(RuntimeError, overall_bar_result.errors.full_messages) unless overall_bar_result.errors.empty?
                  overall_bar_result.calculate_points
                else
                  RACING_ON_RAILS_DEFAULT_LOGGER.warn("WARN: #{discipline_source_result.race.name} has no category")
                end
              end
            end
          end
        end
    
        # if racer has > 4 discipline results, those results are worth 50 points
        for race in overall_standings.races
          for result in race.results
            set_bonus_points_for_extra_disciplines(result.scores)
            result.calculate_points
          end
        end

        # sort overall
        for race in overall_standings.races
          race.results.sort! {|x, y| y.points <=> x.points}
        end
        
        # assign place
        for race in overall_standings.races
          place = 1
          for result in race.results
            result.place = place
            result.save!
            place = place + 1
          end
        end
        
        bar.set_all_last_updated_dates(Date.today)
        
        progress_monitor.increment(1)
        progress_monitor.detail_text = "Finish up"
        bar.save!
        bar.enable_notification!
        progress_monitor.detail_text = ""
        progress_monitor.detail_text = "Idle"
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR BAR progress: #{progress_monitor.progress}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
      end
    }
    RACING_ON_RAILS_DEFAULT_LOGGER.info("BAR #{benchmark}")
    true
  end
  
  def Bar.points_for(scoring_result)
    field_size = scoring_result.race.field_size
    return 0 if field_size <= 4
    
    team_size = Result.count(:conditions => ["race_id =? and place = ?", scoring_result.race.id, scoring_result.place])
    points = POINT_SCHEDULE[scoring_result.place.to_i] * scoring_result.race.bar_points / team_size
    if scoring_result.race.standings.name['CoMotion'] and scoring_result.race.category.name == 'Category C Tandem'
      points = points / 2.0
    end
    if scoring_result.race.bar_points == 1 and field_size >= 75
      points = points * 1.5
    end
    points
  end
  
  # If none of a racer's results in a discipline count for the BAR because the field size is too small,
  # give the racer a 50-point bonus for the overall
  def Bar.overall_points_for(discipline_result)
    if discipline_result.points > 0
      301 - discipline_result.place.to_i
    else
      50
    end
  end

  # TODO Test me
  def Bar.set_bonus_points_for_extra_disciplines(scores)
    scores.sort! {|x, y| y.points.to_i <=> x.points.to_i}
    remove_duplicate_discipline_results(scores)
    if scores.size > 4
      for score in scores[4..(scores.size - 1)]
        score.update_attribute_with_validation_skipping(:points, 50)
      end
    end
  end        
  
  # If racer scored in more than one category that maps to same overall category in a discipline, count only highest-placing category
  # Assume scores sorted by points descending
  def Bar.remove_duplicate_discipline_results(scores)
    disciplines = []
    scores.each do |score|
      if disciplines.include?(score.source_result.race.standings.discipline)
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("Multiple #{score.source_result.race.standings.discipline} results for #{score.source_result.racer}")
        scores.delete(score)
      else
        disciplines << score.source_result.race.standings.discipline
      end
    end
  end
  
  def Bar.create_team_result(scoring_result, bar)
    return unless scoring_result.team and scoring_result.race
    
    teams = extract_teams_from(scoring_result)
    for team in teams
      if team.member
        team_standings = bar.standings.detect {|standings| standings.name == 'Team'}
        team_race = team_standings.races.first
        team_bar_result = team_race.results.detect {|result| result.team == team}
        if team_bar_result.nil?
          team_bar_result = team_race.results.create
          raise(RuntimeError, team_bar_result.errors.full_messages) unless team_bar_result.errors.empty?
          team_bar_result.team = team
          RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR Add new Team BAR result #{team.name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
        else
          RACING_ON_RAILS_DEFAULT_LOGGER.debug("BAR Existing Team BAR result. #{team.name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
        end
        points = POINT_SCHEDULE[scoring_result.place.to_f] / teams.size.to_f
        score = team_bar_result.scores.create(:source_result => scoring_result, :competition_result => team_bar_result, :points => points)
        raise(RuntimeError, score.errors.full_messages) unless score.errors.empty?
        team_bar_result.calculate_points
      end
    end
  end
  
  def Bar.extract_teams_from(scoring_result)
    return unless scoring_result.team
    
    if scoring_result.race.bar_category == Category.find_bar('Tandem')
      teams = []
      team_names = scoring_result.team.name.split("/")
      teams << Team.find_by_name_or_alias_or_create(team_names.first)
      if team_names.size > 1
        name = team_names[1, team_names.size - 1].join("/")
        teams << Team.find_by_name_or_alias_or_create(name)
      end
      teams
    elsif scoring_result.team.name == 'Forza Jet Velo'
      [Team.find_by_name('Half Fast Velo')]
    else
      [scoring_result.team]
    end
  end
  
  # If same ride places twice in same race, only highest result counts
  # This method remove all but highest result
  # Assume results are sorted by place already
  def Bar.racers_best_result_for_each_race(scoring_results)
    best_results = {}
    scoring_results.each do |result|
      key = ResultKey.new(result).freeze
      best_results.rehash
      unless best_results[key]
        best_results[key] = result
      end
    end
    best_results.values
  end
  
  # TODO Just move to initialize
  def Bar.new_yearly_standings(year)
    date = Date.new(year, 1, 1)

    bar = Bar.create!(:date => date, :name => "#{year} BAR")
    
    bar_disciplines = Discipline.find_all_bar
    for discipline in bar_disciplines
      standings = bar.standings.create(
        :event => bar,
        :name => discipline.name,
        :discipline => discipline.name
      )
      raise(RuntimeError, standings.errors.full_messages) unless standings.errors.empty?
      for category in discipline.bar_categories
        race = standings.races.create(:category => category)
      raise(RuntimeError, race.errors.full_messages) unless race.errors.empty?
      end
    end
    
    bar
  end

  # Find BAR races that match the discipline and BAR cat of "result's" race
  # Short-cut for spinning through all of a BAR's standings' races
  # May return multiple races: category + combined
  def find_races(result)
    discipline = result.race.standings.discipline
    discipline_standings = standings.detect {|s| s.name == discipline}
    if discipline_standings == nil
      raise "Could not find '#{discipline}' standings in #{name}'s standings"
    end
    if result.race.category == nil
      RACING_ON_RAILS_DEFAULT_LOGGER.warn("WARN: #{result.race.name} has no category")
      return []
    end
    if result.race.category.bar_category.nil?
      RACING_ON_RAILS_DEFAULT_LOGGER.warn("WARN: #{result.race.category} has no BAR category")
      return []
    end
    
    # Load association
    result.race.bar_category.combined_bar_category(true)
    
    bar_races = discipline_standings.races.select {|bar_race| 
      if bar_race.category.bar_category.nil?
        RACING_ON_RAILS_DEFAULT_LOGGER.warn("WARN: No #{discipline} BAR race for #{bar_race.category}")
        return []
      end
      result.race.bar_category == bar_race.category or result.race.bar_category.combined_bar_category == bar_race.category
    }
    if bar_races == nil or bar_races.empty?
      RACING_ON_RAILS_DEFAULT_LOGGER.warn("WARN: BAR Could not find '#{discipline}' '#{result.race.category}' standings in #{name}'s races")
    end
    bar_races
  end
  
  # Find overall BAR race that matches BAR cat of "result's" race
  # Short-cut for spinning through all of a BAR's standings' races
  def find_overall_race(result)
    bar_category = result.race.bar_category
    raise "Could not find BAR category for #{result.race.category}" if bar_category.nil?

    return if bar_category.overall.nil?

    overall_standings = standings.detect {|s| s.name == "Overall"}
    race = overall_standings.races.detect{|race| 
      race.category.bar_category == bar_category.overall
    }
    raise "Could not find #{bar_category} in #{self}'s races" if race.nil?
    race
  end 
  
  def debug_results
    standings.each {|s|
      puts("BAR")
      puts("BAR #{s.name}")
      s.races.each {|r| 
        puts("BAR")
        puts("BAR   #{r.name}")
        r.results.sort.each {|result|
          puts("BAR      #{result.to_long_s}")
          result.scores.each{|score|
            puts("BAR        #{score.to_s}")
          }
        }
      }
    }
    true
  end

  def to_s
    "<Bar #{id} #{discipline} #{name} #{start_date} #{end_date}>"
  end
end
 
class ResultKey
  
  include Comparable
  
  attr_reader :race_id, :racer_id

  def initialize(result)
    @race_id = result.race.id
    @racer_id = result.racer.id if result.racer
  end
  
  def <=>(other)
    racer_diff = (@racer_id <=> other.racer_id)
    if racer_diff != 0
      racer_diff
    else
      @race_id <=> other.race_id
    end
  end
  
  def hash
    result = 13
    if @racer_id
      result = result + @racer_id * 37     
    end
    # Really should always have race_id ...
    if @race_id
      result = result + @race_id * 37
    end
    result
  end
  
  def eql?(other)
    self == other
  end
  
  def to_s
    "<ResultKey #{@race_id} #{@racer_id}>"
  end
end
