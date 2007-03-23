module Competitions
  class TeamBar < Competition
    # team = scoring_result.team

    def create_team_result(scoring_result)
      return unless scoring_result.team and scoring_result.race

      teams = extract_teams_from(scoring_result)
      for team in teams
        if team.member and (scoring_result.racer.nil? or scoring_result.racer.member?)
          team_standings = standings.detect {|standings| standings.name == 'Team'}
          team_race = team_standings.races.first
          team_bar_result = team_race.results.detect {|result| result.team == team}
          if team_bar_result.nil?
            team_bar_result = team_race.results.create
            raise(RuntimeError, team_bar_result.errors.full_messages) unless team_bar_result.errors.empty?
            team_bar_result.team = team
            logger.debug("BAR Add new Team BAR result #{team.name}") if logger.debug?
          else
            logger.debug("BAR Existing Team BAR result. #{team.name}") if logger.debug?
          end
          points = point_schedule[scoring_result.place.to_f] / teams.size.to_f
          score = team_bar_result.scores.create(:source_result => scoring_result, :competition_result => team_bar_result, :points => points)
          raise(RuntimeError, score.errors.full_messages) unless score.errors.empty?
          team_bar_result.calculate_points
        end
      end
    end

  end

  
  # Simple logic to split team results (tandem, team TTs) between teams
  # Just splits on first slash, so "Bike Gallery/Veloce" becomes "Bike Gallery" and "Veloce"  
  # This method probably gets things wrong sometimes
  # TODO Move this (and maybe other methods) logic to Result or Score
  def extract_teams_from(scoring_result)
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
end