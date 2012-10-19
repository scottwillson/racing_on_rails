# Sum all of Team's discipline BAR's results
# team = source_result.team
class TeamBar < Competition
  include Concerns::Bar::Points

  after_create :set_parent
  
  # Find the source results from discipline BAR's competition results.
  # Could approach this a couple of other ways. This way trades SQL complexity for 
  # less duplicate code
  def source_results(race)
    Result.find_by_sql(
      %Q{SELECT results.*
              FROM results 
              LEFT OUTER JOIN races ON races.id = results.race_id
              LEFT OUTER JOIN events ON races.event_id = events.id
              LEFT OUTER JOIN categories ON races.category_id = categories.id
              where results.id in (select source_result_id
                from scores
                LEFT OUTER JOIN results as competition_results
                  ON competition_results.id = scores.competition_result_id
                LEFT OUTER JOIN races as competition_races
                  ON competition_races.id = competition_results.race_id
                LEFT OUTER JOIN events as competition_events
                  ON competition_races.event_id = competition_events.id
                where competition_events.type = 'Bar'
                  and competition_events.date between'#{date.beginning_of_year}' and '#{date.end_of_year}')
              order by results.team_id}
    )
  end

  # Duplicate calculation of points here with BAR
  # Could derive points from competition_result.scores
  def create_competition_results_for(results, race)
    competition_result = nil
    results.each do |source_result|
      logger.debug("#{self.class.name} scoring result: #{source_result.race.name} #{source_result.place} #{source_result.name} #{source_result.team_name}") if logger.debug?

      teams = extract_teams_from(source_result)
      logger.debug("#{self.class.name} teams for result: #{teams}") if logger.debug?
      teams.each do |team|
        if member?(team, source_result.date)

          if first_result_for_team?(source_result, competition_result)
            # Bit of a hack here, because we split tandem team results into two results,
            # we can't guarantee that results are in team-order.
            # So 'first result' really means 'not the same as last result'
            competition_result = race.results.detect { |result| result.team == team }
            competition_result = race.results.create!(:team => team) if competition_result.nil?
          end

          Score.create!(
            :source_result => source_result, 
            :competition_result => competition_result,
            # Points are divided twice. Once by the size of the team in the result,
            # and then by the number of results with the same place 
            :points => points_for(source_result).to_f / teams.size
          )
        end
      end
    end
  end

  # Simple logic to split team results (tandem, team TTs) between teams
  # Just splits on first slash, so "Bike Gallery/Veloce" becomes "Bike Gallery" and "Veloce"  
  # This method probably gets things wrong sometimes
  def extract_teams_from(source_result)
    return [] unless source_result.team
  
    if source_result.race.category.name.include?("Tandem")
      teams = []
      team_names = source_result.team.name.split("/")
      teams << Team.find_by_name_or_alias_or_create(team_names.first)
      if team_names.size > 1
        name = team_names[1, team_names.size - 1].join("/")
        teams << Team.find_by_name_or_alias_or_create(name)
      end
      teams
    elsif source_result.team.name == "Forza Jet Velo"
      [ Team.find_or_create_by_name("Half Fast Velo") ]
    else
      [ source_result.team ]
    end
  end

  def consider_team_size?
    true
  end
  
  def set_parent
    if parent.nil?
      self.parent = OverallBar.find_or_create_for_year(year)
      save!
    end
  end

  def default_discipline
    "Team"
  end

  def friendly_name
    "Team BAR"
  end
end
