# frozen_string_literal: true

require_relative "../../v3"

# :stopdoc:
class Calculations::V3::Models::CalculatedResultTest < Ruby::TestCase
  def test_initialize
    category = Calculations::V3::Models::Category.new("A")
    event_category = Calculations::V3::Models::EventCategory.new(category)
    sources = [Calculations::V3::Models::SourceResult.new(id: 11, event_category: event_category)]
    participant = Calculations::V3::Models::Participant.new(1)

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
