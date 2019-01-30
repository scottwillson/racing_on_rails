# frozen_string_literal: true

require_relative "../../v3"

module Calculations
  module V3
    module Models
      # :stopdoc:
      class ParticipantTest < Ruby::TestCase
        def test_initialize
          participant = Participant.new(9)
          assert_equal 9, participant.id
        end
      end
    end
  end
end
