require_relative "default_result_renderer"

module Renderers
  class TimeRenderer < Renderers::DefaultResultRenderer
    def self.render(column, row)
      time = row[key(column)]
      return nil if time.nil?
      
      seconds = time % 60
      minutes = (time / 60) % 60
      hours = time / (60 * 60)

      precision = [ column.precision, 3 ].min
      if precision == 0
        case column.max
        when 60..3599
          format "%02d:%02d", minutes, seconds
        when 0..59
          format "%02d", seconds
        when 0
          format "0"
        else
          format "%d:%02d:%02d", hours, minutes, seconds
        end
      else
        case column.max
        when 60..3599
          format "%02d:%0#{precision + 3}.#{precision}f", minutes, seconds
        when 0..59
          format "%0#{precision + 3}.#{precision}f", seconds
        when 0
          format "0"
        else
          format "%d:%02d:%0#{precision + 3}.#{precision}f", hours, minutes, seconds
        end
      end
    end
  end
end
