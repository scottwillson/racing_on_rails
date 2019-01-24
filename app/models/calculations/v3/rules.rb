# frozen_string_literal: true

class Calculations::V3::Rules
  attr_reader :categories
  attr_reader :points_for_place

  def initialize(categories: [], points_for_place: nil)
    @categories = categories
    @points_for_place = points_for_place
  end
end
