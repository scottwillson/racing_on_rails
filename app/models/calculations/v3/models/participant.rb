# frozen_string_literal: true

# Person or team that owns a result. Teams can be permanent year-long teams,
# or event-only teams.
class Calculations::V3::Models::Participant
  attr_reader :id

  def initialize(id)
    @id = id
  end
end
