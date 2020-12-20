# frozen_string_literal: true

require_relative "default_result_renderer"

module Results
  module Renderers
    class TeamNameRenderer < Results::Renderers::DefaultResultRenderer
      def self.render(column, row)
        result = row.source
        text = row[column.key]
        return text unless result.team_id

        if result.calculation_result?
          "<a href=\"/calculations/results/#{result.id}\">#{text}</a>"

        elsif result.team_competition_result?
          "<a href=\"/events/#{result.event_id}/teams/#{result.team_id}/results##{result.race_id}\">#{text}</a>"

        elsif racing_association.unregistered_teams_in_results? ||
              result.team_member? ||
              result.year < racing_association.year

          "<a href=\"/teams/#{result.team_id}/#{result.year}\">#{text}</a>"
        end
      end

      def self.racing_association
        RacingAssociation.current
      end
    end
  end
end
