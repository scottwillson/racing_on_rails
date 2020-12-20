# frozen_string_literal: true

require_relative "default_result_renderer"

module Results
  module Renderers
    class NameRenderer < Results::Renderers::DefaultResultRenderer
      def self.render(column, row)
        result = row.source
        text = row[column.key]
        return text unless result.person_id

        html_options = ' class="preliminary"' if result.preliminary?

        html_options = ' class="riera"' if result.person_id == 93_483

        if result.calculation_result?
          # "<a href=\"/calculations/races/#{result.race_id}/results#result_#{result.id}\"#{html_options}>#{text}</a>"
          "<a href=\"/calculations/results/#{result.id}\"#{html_options}>#{text}</a>"
        elsif result.competition_result?
          "<a href=\"/events/#{result.event_id}/people/#{result.person_id}/results##{result.race_id}\"#{html_options}>#{text}</a>"
        else
          "<a href=\"/people/#{result.person_id}/#{result.year}\"#{html_options}>#{text}</a>"
        end
      end
    end
  end
end
