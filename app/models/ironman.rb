# Who has done the most events? Just counts starts/appearences in results. Not pefect -- some events
# are probably over-counted.
class Ironman < Competition
  def friendly_name
    'Ironman'
  end

  # TODO Can't we just iterate through all of a racer's results? Would need to weed out many results
  def Ironman.years
    years = []
    results = connection.select_all(
      "select distinct extract(year from date) as year from events where type = 'Ironman'"
    )
    results.each do |year|
      years << year.values.first.to_i
    end
    years.sort.reverse
  end
  
  def points_for(source_result)
    1
  end
  
  def break_ties?
    false
  end
  
  def source_results(race)
    Result.find_by_sql(
      %Q{SELECT results.id as id, race_id, racer_id, team_id, place FROM results  
         LEFT OUTER JOIN races ON races.id = results.race_id 
         LEFT OUTER JOIN standings ON races.standings_id = standings.id 
         LEFT OUTER JOIN events ON standings.event_id = events.id 
         WHERE (races.category_id is not null 
           and events.type = 'SingleDayEvent' 
           and standings.ironman = true 
           and standings.date >= '#{year}-01-01' 
           and standings.date <= '#{year}-12-31')
         ORDER BY racer_id}
    )
  end
    
  def expire_cache
    Ironman.expire_cache
  end
end