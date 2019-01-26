# frozen_string_literal: true

# Result from event. Typically, from a rider crossing a finish line,
# but could be calculated by another calculated event. For example, Road BAR
# and Overall BAR.
class Calculations::V3::Models::SourceResult
  attr_reader :id
  attr_reader :participant
  attr_accessor :place
  attr_accessor :points

  def initialize(id: nil, participant: nil, place: nil)
    @id = id
    @participant = participant
    @place = place

    validate!
  end

  def numeric_place
    place&.to_i || 0
  end

  def rejected?
    false
  end

  def validate!
    raise(ArgumentError, "id is required") unless id
    raise(ArgumentError, "id must be a Numeric") unless id.is_a?(Numeric)
  end
end
