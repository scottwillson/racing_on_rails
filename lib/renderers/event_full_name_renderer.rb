require_relative "default_result_renderer"

module Renderers
  class EventFullNameRenderer < Renderers::DefaultResultRenderer
    def self.render(column, row)
      "<a href=\"/events/#{row.source.event_id}/results#race_#{row.source.race_id}\">#{row[column.key]}</a>"
    end
  end
end
