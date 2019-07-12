# frozen_string_literal: true

module Calculations
  module V3
    module Models
      # Result calculated from source results. Belongs to EventCategory.
      class CalculatedResult
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

        def not_rejected?
          !rejected?
        end

        def placed_source_results
          source_results.select(&:placed?)
        end

        def placed_source_results_with_points
          placed_source_results.select(&:points?)
        end

        def points?
          points&.positive?
        end

        def reject(reason)
          raise(ArgumentError, "already rejected because #{rejection_reason}") if rejected?

          @rejection_reason = reason
          @rejected = true
        end

        def rejected?
          @rejected
        end

        def source_result_ability
          source_results.first.ability
        end

        def source_result_numeric_place
          source_results.first.numeric_place
        end

        def source_result_placed?
          source_results.first.placed?
        end

        def source_result_rejected?
          source_results.first.rejected?
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
