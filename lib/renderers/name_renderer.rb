require_relative "default_result_renderer"

module Renderers
  class NameRenderer < Renderers::DefaultResultRenderer
    def self.render(column, row)
      result = row.source
      text = row[column.key]
      return text unless result.person_id

      if result.preliminary?
        html_options = ' class="preliminary"'
      end
    
      if result.competition_result?
        "<a href=\"/events/#{result.event_id}/people/#{result.person_id}/results##{result.race_id}\"#{html_options}>#{text}</a>"
      else
        "<a href=\"/people/#{result.person_id}/#{result.year}\"#{html_options}>#{text}</a>"
      end
    end
  end
end
