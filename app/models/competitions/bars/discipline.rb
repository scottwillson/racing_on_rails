module Competitions
  module Bars
    module Discipline
      def disciplines_for(race)
        case race.discipline
        when "Road"
          [ "Road", "Circuit" ]
        when "Mountain Bike"
          [ "Mountain Bike", "Downhill", "Super D" ]
        else
          [ race.discipline ]
        end
      end
    end
  end
end
