require_relative "default_result_renderer"

module Results
  module Renderers
    class PointsRenderer < Results::Renderers::DefaultResultRenderer
      def self.render(column, row)
        if row[column.key] && row[column.key].to_f > 0
          format "%0.#{column.precision}f", row[column.key]
        else
          ""
        end
      end
    end
  end
end
