# frozen_string_literal: true

require_relative "../../../../test_case"
require_relative "../../../../../../app/models/calculations"
require_relative "../../../../../../app/models/calculations/v3"
require_relative "../../../../../../app/models/calculations/v3/models"
require_relative "../../../../../../app/models/calculations/v3/models/participant"

# :stopdoc:
class Calculations::V3::Models::ParticipantTest < Ruby::TestCase
  def test_initialize
    participant = Calculations::V3::Models::Participant.new(9)
    assert_equal 9, participant.id
  end
end
