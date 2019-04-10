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
          refute participant.member?
        end

        def test_member
          participant = Participant.new(9, membership: (Date.new(2012, 1, 1)..(Date.new(2018, 12, 31))))
          refute participant.member?

          participant = Participant.new(9, membership: (Date.new(2012, 1, 1)..(Date.today.next_year)))
          assert participant.member?
        end
      end
    end
  end
end
