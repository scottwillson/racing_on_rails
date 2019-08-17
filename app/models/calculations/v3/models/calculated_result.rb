# frozen_string_literal: true

module Calculations
  module V3
    module Models
      # Result calculated from source results. Belongs to EventCategory.
      class CalculatedResult
        include Calculations::V3::Models::Results

        attr_reader :participant
        attr_accessor :place
        attr_accessor :points
        attr_accessor :rejection_reason
        attr_accessor :tied
        attr_reader :source_results
        attr_reader :time

        def initialize(participant, source_results)
          @participant = participant
          @rejected = false
          @source_results = source_results
          @tied = false

          @time = source_results&.first&.time

          validate!
        end

        def placed_source_results
          source_results.select(&:placed?)
        end

        def placed_source_results_with_points
          placed_source_results.select(&:points?)
        end

        def source_result_ability
          source_results.first.ability
        end

        # Awkward. Consider "0" abilities like Clydesdale and Pro as 1.
        def source_result_ability_group
          if source_result_ability == 0
            return 1
          end

          source_result_ability
        end

        def source_result_numeric_place
          source_results.first.numeric_place
        end

        def source_result_placed?
          source_results.first.placed?
        end

        def tied?
          @tied
        end

        def time?
          !time.nil?
        end

        def unrejected_source_results
          source_results.reject(&:rejected?)
        end

        def validate!
          raise(ArgumentError, "participant is required") unless participant
          raise(ArgumentError, "source_results is required") unless source_results
          raise(ArgumentError, "source_results must be an Enumerable") unless source_results.is_a?(Enumerable)
          raise(ArgumentError, "source_results cannot be empty") if source_results.empty?

          unless source_results.all? { |source_result| source_result.is_a?(Calculations::V3::Models::SourceResult) }
            raise(ArgumentError, "source_results must all be Models::SourceResult")
          end
        end

        def validate_one_source_result!
          if source_results.size != 1
            raise(ArgumentError, "results placed by place or time must have exactly one source result, but has #{source_results.size}")
          end
        end

        delegate :id, to: :participant, prefix: true
      end
    end
  end
end
