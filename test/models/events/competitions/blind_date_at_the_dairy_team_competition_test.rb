require "test_helper"

module Competitions
  # :stopdoc:
  class BlindDateAtTheDairyTeamCompetitionTest < ActiveSupport::TestCase
    test "calculate" do
      BlindDateAtTheDairyTeamCompetition.calculate!
    end
  end
end
