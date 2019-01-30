# frozen_string_literal: true

require_relative "../../v3"

# :stopdoc:
class Calculations::V3::Models::ParticipantTest < Ruby::TestCase
  def test_initialize
    participant = Calculations::V3::Models::Participant.new(9)
    assert_equal 9, participant.id
  end
end
