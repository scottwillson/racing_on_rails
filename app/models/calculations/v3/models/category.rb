# frozen_string_literal: true

# Canonical category with name, ability, age, etc. Not associated with an individual event.
# EventCategory joins a Category with an event.
class Calculations::V3::Models::Category
  attr_reader :name

  def initialize(name)
    @name = name
  end
end
