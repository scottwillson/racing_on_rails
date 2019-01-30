# frozen_string_literal: true

module Calculations
  module V3
    # Calculation-specific model, similar, but not identical to ActiveRecord model/DB schema.
    # Separated mainly to ensure calculations are all in memory and never connect to the DB:
    # * easier to test
    # * fast
    # * precise abstraction
    # * duplicates already-rich domain model
    # * difficult to share code
    module Models
    end
  end
end
