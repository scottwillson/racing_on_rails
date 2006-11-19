# Who has done the most events? Just counts starts/appearences in results. Not pefect -- some events
# are probably over-counted.
class Ironman < Competition

  # TODO Can't we just iterate through all of a racer's results? Would need to weed out many results
  # TODO Consider some straight SQL for this
  
  # Calculate clashs with internal Rails method
  def Ironman.recalculate(year = Date.today.year)
    RACING_ON_RAILS_DEFAULT_LOGGER.info("Ironman Calculate")
    year = year.to_i if year.is_a?(String)
    Ironman.transaction do
      existing_ironman = Ironman.find_by_date("#{year}-01-01")
      if (existing_ironman)
        existing_ironman.destroy_standings
        existing_ironman.destroy
      end
      ironman = Ironman.new_yearly_standings(year)
      ironman.disable_notification!
      
      RACING_ON_RAILS_DEFAULT_LOGGER.debug("Ironman Finding results") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
      scoring_results = Result.find_by_sql(
        %Q{SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
           LEFT OUTER JOIN races ON races.id = results.race_id 
           LEFT OUTER JOIN standings ON races.standings_id = standings.id 
           LEFT OUTER JOIN events ON standings.event_id = events.id 
           WHERE (races.category_id is not null 
             and events.type = 'SingleDayEvent' 
             and standings.ironman = true 
             and standings.date >= '#{year}-01-01' 
             and standings.date <= '#{year}-12-31')}
      )
  
      ironman_race = ironman.standings.first.races.first
      for scoring_result in scoring_results.sort!
        RACING_ON_RAILS_DEFAULT_LOGGER.debug("Ironman scoring result: #{scoring_result.race.name} #{scoring_result.place} #{scoring_result.last_name} #{scoring_result.team_name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
        racer = scoring_result.racer
        if racer
          ironman_result = ironman_race.results.detect {|result| result.racer == racer}
          if ironman_result.nil?
            ironman_result = ironman_race.results.create
            ironman_result.racer = racer
            ironman_result.team = scoring_result.team
            RACING_ON_RAILS_DEFAULT_LOGGER.debug("Ironman Add new Ironman result to #{ironman_race.name} for #{racer.last_name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
          else
            RACING_ON_RAILS_DEFAULT_LOGGER.debug("Ironman Existing Ironman result. #{ironman_result.last_name}") if RACING_ON_RAILS_DEFAULT_LOGGER.debug?
          end
          score = Score.new(:source_result => scoring_result, :competition_result => ironman_result, :points => 1)
          ironman_result.scores << score
          ironman_result.calculate_points
        end
      end
  
      # sort overall
      ironman_race.results.sort! {|x, y| y.points <=> x.points}
      
      # assign place
      place = 1
      for result in ironman_race.results
        result.place = place
        result.save!
        place = place + 1
      end
      
      ironman.save!
      ironman.enable_notification!
    end
  end
  
  # TODO Just move to initialize
  def Ironman.new_yearly_standings(year)
    date = Date.new(year, 1, 1)

    ironman = Ironman.create(:date => date)
    ironman.name = "#{year} Ironman"
    
    standings = ironman.standings.create({
      :name => ironman.name
    })
    category = Category.find_or_create_by_name_and_scheme('Ironman', 'Competition')
    standings.races.create({
      :category => category
    })

    ironman
  end
end