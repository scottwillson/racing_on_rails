# frozen_string_literal: true

require_relative "../../../../test_case"
require_relative "../../../../../../app/models/calculations"
require_relative "../../../../../../app/models/calculations/v3"
require_relative "../../../../../../app/models/calculations/v3/models"
require_relative "../../../../../../app/models/calculations/v3/models/calculated_result"
require_relative "../../../../../../app/models/calculations/v3/models/source_result"

# :stopdoc:
class Calculations::V3::Models::CalculatedResultTest < Ruby::TestCase
  def test_initialize
    participant = Calculations::V3::Models::Participant.new(1)
    sources = [Calculations::V3::Models::SourceResult.new(id: 11)]

    result = Calculations::V3::Models::CalculatedResult.new(participant, sources)

    assert_equal participant, result.participant
    assert_equal sources, result.source_results
  end

  def test_participant
    assert_raises(ArgumentError) { Calculations::V3::Models::CalculatedResult.new(nil) }
  end

  def test_sources
    assert_raises(ArgumentError) { Calculations::V3::Models::CalculatedResult.new(1, nil) }
    assert_raises(ArgumentError) { Calculations::V3::Models::CalculatedResult.new(2, []) }
    assert_raises(ArgumentError) { Calculations::V3::Models::CalculatedResult.new(2, "") }
  end
end
