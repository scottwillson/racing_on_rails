module Competitions
  class BlindDateAtTheDairyOverall < Overall
    include Competitions::BlindDateAtTheDairy::Common

    def maximum_events(race)
      4
    end

    def after_calculate
      super

      race = races.detect { |r| r.name == "Beginner" }
      if race
        race.update_attributes! visible: false
      end

      BlindDateAtTheDairyMonthlyStandings.calculate!
    end
  end
end
