# team = source_result.team
# FIXME: Can't just sum up person results -- need to get source race results
# Example:
# 5th  Banana Belt Road Race  
#
# TODO Consolidate with other BARs. Consider subclasses
class TeamBar < Competition
  after_create :set_parent
  
  def point_schedule
    [0, 30, 25, 22, 19, 17, 15, 13, 11, 9, 7, 5, 4, 3, 2, 1]
  end

  # Find the source results from discipline BAR's competition results.
  # Could approach this a couple of other ways. This way trades SQL complexity for 
  # less duplicate code
  def source_results(race)
    Result.find_by_sql(
      %Q{SELECT results.points, results.id as id, race_id, person_id, results.team_id, place
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
                  and competition_events.date >= '#{date.year}-01-01'
                  and competition_events.date <= '#{date.year}-12-31')
              order by team_id}
    )
  end

  # FIXME Check that team size is considered correctly
  # Duplicate calculation of points here with BAR
  # Could derive points from competition_result.scores
  def create_competition_results_for(results, race)
    competition_result = nil
    for source_result in results
      logger.debug("#{self.class.name} scoring result: #{source_result.race.name} #{source_result.place} #{source_result.name} #{source_result.team_name}") if logger.debug?

      teams = extract_teams_from(source_result)
      logger.debug("#{self.class.name} teams for result: #{teams}") if logger.debug?
      for team in teams
        if member?(team, source_result.date)

          if first_result_for_team(source_result, competition_result)
            # Bit of a hack here, because we split tandem team results into two results,
            # we can't guarantee that results are in team-order.
            # So 'first result' really means 'not the same as last result'
            competition_result = race.results.detect {|result| result.team == team}
            competition_result = race.results.create(:team => team) if competition_result.nil?
          end

          score = competition_result.scores.create(
            :source_result => source_result, 
            :competition_result => competition_result, 
            :points => points_for(source_result).to_f / teams.size
          )
        end
      end
    end
  end

  # Simple logic to split team results (tandem, team TTs) between teams
  # Just splits on first slash, so "Bike Gallery/Veloce" becomes "Bike Gallery" and "Veloce"  
  # This method probably gets things wrong sometimes
  # TODO Move this (and maybe other methods) logic to Result or Score
  def extract_teams_from(source_result)
    return [] unless source_result.team
  
    if source_result.race.category.name.include?('Tandem')
      teams = []
      team_names = source_result.team.name.split("/")
      teams << Team.find_by_name_or_alias_or_create(team_names.first)
      if team_names.size > 1
        name = team_names[1, team_names.size - 1].join("/")
        teams << Team.find_by_name_or_alias_or_create(name)
      end
      teams
    elsif source_result.team.name == 'Forza Jet Velo'
      [Team.find_or_create_by_name('Half Fast Velo')]
    else
      [source_result.team]
    end
  end

  def first_result_for_team(source_result, competition_result)
    competition_result.nil? || source_result.team != competition_result.team
  end

  # Apply points from point_schedule, and adjust for field size
  def points_for(source_result, team_size = nil)
    # TODO Consider indexing place
    # TODO Consider caching/precalculating team size
    points = 0
    Bar.benchmark('points_for') {
      field_size = source_result.race.field_size

      team_size = team_size || Result.count(:conditions => ["race_id =? and place = ?", source_result.race.id, source_result.place])
      points = point_schedule[source_result.place.to_i] * source_result.race.bar_points / team_size.to_f
      if source_result.race.bar_points == 1 and field_size >= 75
        points = points * 1.5
      end
    }
    points
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
    'Team BAR'
  end
end
