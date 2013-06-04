require_relative "default_result_renderer"

module Renderers
  class TeamNameRenderer < Renderers::DefaultResultRenderer
    def self.render(column, row)
      result = row.source
      text = row[column.key]
      return text unless result.team_id

      if racing_association.unregistered_teams_in_results? || 
        result.team_member? || 
        result.year < racing_association.year
      
        if result.team_competition_result?
          "<a href=\"/events/#{result.event_id}/teams/#{result.team_id}/results/#{result.race_id}\">#{text}</a>"
        else
          "<a href=\"/teams/#{result.team_id}/#{result.year}\">#{text}</a>"
        end
      end
    end
    
    def self.racing_association
      RacingAssociation.current
    end
  end
end
