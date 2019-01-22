# frozen_string_literal: true

# A Category with results (CalculatedResult or SourceResult?).
# A "Race" in the older domain model.
class Calculations::V3::Models::EventCategory
  attr_reader :category

  def initialize(category)
    @category = category
  end

  def name # rubocop:disable Rails/Delegate
    category.name
  end

  def results
    @results ||= []
  end
end
