# frozen_string_literal: true

module Competitions
  module Bars
    module Discipline
      def disciplines_for(race)
        case race.discipline
        when "Road"
          [ "Road", "Road/Gravel", "Circuit" ]
        when "Mountain Bike"
          [ "Mountain Bike", "Downhill", "Super D" ]
        else
          [ race.discipline ]
        end
      end
    end
  end
end
