# frozen_string_literal: true

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

  def validate!
    raise(ArgumentError, "id is required") unless id
    raise(ArgumentError, "id must be a Numeric") unless id.is_a?(Numeric)
  end
end
