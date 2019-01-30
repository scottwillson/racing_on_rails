# frozen_string_literal: true

require_relative "../../../../test_case"
require_relative "../../../../../../app/models/calculations"
require_relative "../../../../../../app/models/calculations/v3"
require_relative "../../../../../../app/models/calculations/v3/models"
require_relative "../../../../../../app/models/calculations/v3/models/category"
require_relative "../../../../../../app/models/calculations/v3/models/event_category"
require_relative "../../../../../../app/models/calculations/v3/models/participant"
require_relative "../../../../../../app/models/calculations/v3/models/source_result"

# :stopdoc:
class Calculations::V3::Models::EventCategoryTest < Ruby::TestCase
  def test_initialize
    participant = Calculations::V3::Models::Participant.new(1)
    category = Calculations::V3::Models::Category.new("Juniors")
    sources = [
      Calculations::V3::Models::SourceResult.new(id: 11, event_category: Calculations::V3::Models::EventCategory.new(category)),
      Calculations::V3::Models::SourceResult.new(id: 13, event_category: Calculations::V3::Models::EventCategory.new(category))
    ]

    result = Calculations::V3::Models::CalculatedResult.new(participant, sources)
    event_category = Calculations::V3::Models::EventCategory.new(category)
    event_category.results << result
  end
end
