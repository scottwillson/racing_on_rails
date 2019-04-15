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
          refute participant.member?(2019)
        end

        def test_member
          participant = Participant.new(9, membership: (Date.new(2012, 1, 1)..(Date.new(2018, 12, 31))))
          assert participant.member?(2018)

          participant = Participant.new(9, membership: (Date.new(2012, 1, 1)..(Date.new(2018, 12, 31))))
          refute participant.member?(2019)

          participant = Participant.new(9, membership: (Date.new(2012, 1, 1)..(Date.today.next_year)))
          assert participant.member?(2019)
        end
      end
    end
  end
end
