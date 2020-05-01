# frozen_string_literal: true

module Competitions
  class BlindDateAtTheDairyOverall < Overall
    include Competitions::BlindDateAtTheDairy::Common

    def maximum_events(_race)
      4
    end

    def after_calculate
      super

      race = races.detect { |r| r.name == "Beginner" }
      race&.update! visible: false

      BlindDateAtTheDairyMonthlyStandings.calculate!
    end
  end
end
