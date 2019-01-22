# frozen_string_literal: true

class Calculations::V3::Models::EventCategory
  attr_reader :category

  def initialize(category)
    @category = category
  end

  def name
    category.name
  end

  def results
    @results ||= []
  end
end
