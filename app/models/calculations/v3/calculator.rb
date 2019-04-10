# frozen_string_literal: true

require "benchmark"
require "logger"

module Calculations
  module V3
    # Inputs:
    #   * Calculation rules
    #   * results as model SourceResults
    #
    # Steps
    #   1. Transform source results into array of calculated event categories
    #      with a calculated result for each unique participant
    #      * each source result belongs to a calculated result
    #      * every calculated has at least one source result
    #      * source results may be duplicated later (for upgrades)
    #      * cycle through each source result, find best match event category, add or create calculated result, add source result?
    #   2. assign points
    #   3. create upgrade results
    #   4. assign points again? What is sequence for upgrades?
    #   5. sum points
    #   6. place results (skip zero-results?)
    # many missing steps ...
    class Calculator
      attr_reader :event_categories
      attr_reader :rules
      attr_reader :source_results

      def initialize(logger: Logger.new(STDOUT, level: :fatal), rules: Rules.new, source_results: [])
        raise(ArgumentError, "rules should be Rules, but are #{rules.class}") unless rules.is_a?(Rules)

        @logger = logger
        @rules = rules
        @source_results = source_results

        @event_categories = create_event_categories
      end

      def create_event_categories
        if rules.categories?
          rules.categories.map do |category|
            Models::EventCategory.new(category)
          end
        else
          [Models::EventCategory.new(Models::Category.new("Calculation"))]
        end
      end

      # Do the work, all in memory with Ruby classes
      def calculate!
        @logger.debug "Calculator#calculate! source_results: #{source_results.size} rules: #{rules.to_h}"

        calculate_step(Steps::MapSourceResultsToResults)
          .calculate_step(Steps::RejectCalculatedEvents)
          .calculate_step(Steps::RejectWeekdayEvents)
          .calculate_step(Steps::SelectInDiscipline)
          .calculate_step(Steps::RejectCategories)
          .calculate_step(Steps::RejectNoParticipant)
          .calculate_step(Steps::SelectMembers)
          .calculate_step(Steps::RejectDnfs)
          .calculate_step(Steps::RejectBelowMinimumEvents)
          .calculate_step(Steps::AssignPoints)
          .calculate_step(Steps::RejectMoreThanMaximumEvents)
          .calculate_step(Steps::SumPoints)
          .calculate_step(Steps::Place)
          .event_categories
      end

      def calculate_step(step)
        results_count_before = @event_categories.flat_map(&:results).size
        rejections_count_before = @event_categories.flat_map(&:results).select(&:rejected?).size
        source_results_count_before = @event_categories.flat_map(&:results).flat_map(&:source_results).size
        source_result_rejections_count_before = @event_categories.flat_map(&:results).flat_map(&:source_results).select(&:rejected?).size

        time = Benchmark.measure do
          @event_categories = step.calculate!(self)
        end

        results_count_after = @event_categories.flat_map(&:results).size
        rejections_count_after = @event_categories.flat_map(&:results).select(&:rejected?).size
        source_results_count_after = @event_categories.flat_map(&:results).flat_map(&:source_results).size
        source_result_rejections_count_after = @event_categories.flat_map(&:results).flat_map(&:source_results).select(&:rejected?).size
        formatted_time = format("%.1fms", time.real)
        @logger.debug(<<~MSG
          Steps::#{step}#calculate!
          duration: #{formatted_time}
          results: #{results_count_after - results_count_before}
          rejections: #{rejections_count_after - rejections_count_before}
          source_results: #{source_results_count_after - source_results_count_before}
          source_result_rejections: #{source_result_rejections_count_after - source_result_rejections_count_before}
        MSG
                     )

        self
      end

      def validate!
        if event_categories.size != event_categories.uniq.size
          raise("Duplicate categories in #{event_categories.map(&:name).sort}")
        end
      end
    end
  end
end
