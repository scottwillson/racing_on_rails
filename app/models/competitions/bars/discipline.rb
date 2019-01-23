# frozen_string_literal: true

module Competitions
  module Bars
    module Discipline
      def disciplines_for(race)
        case race.discipline
        when "Road"
          ["Road", "Circuit"]
        when "Gravel"
          ["Gravel", "Gran Fondo"]
        when "Mountain Bike"
          ["Mountain Bike", "Downhill", "Super D"]
        else
          [race.discipline]
        end
      end
    end
  end
end
