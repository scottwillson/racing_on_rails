# frozen_string_literal: true

module Calculations
  module V3
    module Models
      # Result calculated from source results. Belongs to EventCategory.
      class CalculatedResult
        attr_reader :participant
        attr_accessor :place
        attr_accessor :points
        attr_reader :source_results

        def initialize(participant, source_results)
          @participant = participant
          @source_results = source_results

          validate!
        end

        def validate!
          raise(ArgumentError, "participant is required") unless participant
          raise(ArgumentError, "source_results is required") unless source_results
          raise(ArgumentError, "source_results must be an Enumerable") unless source_results.is_a?(Enumerable)
          raise(ArgumentError, "source_results cannot be empty") if source_results.empty?
        end
      end
    end
  end
end
