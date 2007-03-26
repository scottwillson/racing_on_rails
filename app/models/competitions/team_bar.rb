# team = source_result.team
# FIXME: Can't just sum up racer results -- need to get source race results
# Example:
# 5th  Banana Belt Road Race  
#
# TODO Consolidate with other BARs. Consider subclasses
module Competitions
  class TeamBar < Competition
    
    def point_schedule
      [0, 30, 25, 22, 19, 17, 15, 13, 11, 9, 7, 5, 4, 3, 2, 1]
    end

    # Find the source results from discipline BAR's competition results.
    # Could approach this a couple of other ways. This way trades SQL complexity for 
    # less duplicate code
    def source_results(race)
      Result.find_by_sql(
        %Q{SELECT results.id as id, race_id, racer_id, team_id, place 
            FROM results  
            LEFT OUTER JOIN races ON races.id = results.race_id 
            LEFT OUTER JOIN standings ON races.standings_id = standings.id 
            LEFT OUTER JOIN events ON standings.event_id = events.id 
            LEFT OUTER JOIN categories ON races.category_id = categories.id 
            where results.id in (select source_result_id 
                         from scores 
                         LEFT OUTER JOIN results as competition_results 
                          ON competition_results.id = scores.competition_result_id
                         LEFT OUTER JOIN races as competition_races 
                          ON competition_races.id = competition_results.race_id
                         LEFT OUTER JOIN standings as competition_standings 
                          ON competition_races.standings_id = competition_standings.id 
                         LEFT OUTER JOIN events as competition_events 
                          ON competition_standings.event_id = competition_events.id 
                         where competition_events.type = 'Bar' 
                           and competition_standings.date >= '#{date.year}-01-01' 
                           and competition_standings.date <= '#{date.year}-12-31')
            order by team_id}
      )
    end

    # FIXME Check that team size is considered correctly
    def create_competition_results_for(results, race)
      competition_result = nil
      for source_result in results
        logger.debug("#{self.class.name} scoring result: #{source_result.race.name} #{source_result.place} #{source_result.last_name} #{source_result.team_name}") if logger.debug?

        teams = extract_teams_from(source_result)
        logger.debug("#{self.class.name} teams for result: #{teams}") if logger.debug?
        for team in teams
          if member?(team, source_result.race.standings.date)

            if first_result_for_team(source_result, competition_result)
              # Bit of a hack here, because we split tandem team results into two results,
              # we can't gurantee that results are in team-order.
              # So 'first result' really means 'not the same as last result'
              competition_result = race.results.detect {|result| result.team == team}
              competition_result = race.results.create(:team => team) if competition_result.nil?
            end

            score = competition_result.scores.create(
              :source_result => source_result, 
              :competition_result => competition_result, 
              :points => points_for(source_result).to_f / teams.size
            )
            # TODO Need to do this every time? Maybe before save?
            competition_result.calculate_points
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
  
    # Expire BAR web pages from cache. Expires *all* BAR pages. Shouldn't be in the model, either
    # BarSweeper seems to fire, but does not expire pages?
    def TeamBar.expire_cache
      FileUtils::rm_rf("#{RAILS_ROOT}/public/bar.html")
      FileUtils::rm_rf("#{RAILS_ROOT}/public/bar")
    end

    def friendly_name
      'Team BAR'
    end
  end

end