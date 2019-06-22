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
    #      * every calculated result has at least one source result
    #      * source results may be duplicated later (for upgrades)
    #   2. assign points
    #   3. create upgrade results
    #   4. assign points again? What is sequence for upgrades?
    #   5. sum points
    #   6. place results (skip zero-results?)
    # many missing steps ...
    #
    # Result outcomes. The division between 1, 2, and 3 is subjective and tries
    # to answer "why didn't this result count?" without clutter.
    #   1. Rejected by initial SQL query (e.g., different year)
    #   2. Rejected for reasons like a different discipline. Not shown in final
    #      results.
    #   3. Selected, but marked as rejected (membership required)
    #   4. Selected, but not assigned points (lower places, "best of")
    #   5. Selected and assigned points
    class Calculator
      attr_reader :event_categories
      attr_reader :rules
      attr_reader :year

      def initialize(logger: Logger.new(STDOUT, level: :fatal), rules: Rules.new, source_results: [], year: Date.today.year)
        raise(ArgumentError, "rules should be Rules, but are #{rules.class}") unless rules.is_a?(Rules)

        @logger = logger
        @rules = rules
        @year = year

        @event_categories = create_event_categories
        map_source_results_to_results source_results
      end

      def create_event_categories
        if categories?
          categories.map do |category|
            Models::EventCategory.new(category)
          end
        elsif team?
          [Models::EventCategory.new(Models::Category.new("Team"))]
        else
          [Models::EventCategory.new(Models::Category.new("Calculation"))]
        end
      end

      # Do the work, all in memory with Ruby classes
      def calculate!
        @logger.debug "Calculator#calculate! source_results: #{source_results.size} rules: #{rules.to_h}"

        calculate_step(Steps::RejectCalculatedEvents)
          .calculate_step(Steps::RejectWeekdayEvents)
          .calculate_step(Steps::SelectInDiscipline)
          .calculate_step(Steps::RejectCategories)
          .calculate_step(Steps::RejectNoParticipant)
          .calculate_step(Steps::SelectAssociationSanctioned)
          .calculate_step(Steps::SelectMembers)
          .calculate_step(Steps::RejectDnfs)
          .calculate_step(Steps::RejectBelowMinimumEvents)
          .calculate_step(Steps::RejectMoreThanResultsPerEvent)
          .calculate_step(Steps::AssignPoints)
          .calculate_step(Steps::AddMissingResultsPenalty)
          .calculate_step(Steps::RejectMoreThanMaximumEvents)
          .calculate_step(Steps::RejectEmptySourceResults)
          .calculate_step(Steps::SumPoints)
          .calculate_step(Steps::Place)
          .event_categories
      end

      def calculate_step(step)
        results_count_before = results.size
        rejections_count_before = results.select(&:rejected?).size
        source_results_count_before = source_results.size
        source_result_rejections_count_before = source_results.select(&:rejected?).size

        time = Benchmark.measure do
          @event_categories = step.calculate!(self)
        end

        results_count_after = results.size
        rejections_count_after = results.select(&:rejected?).size
        source_results_count_after = source_results.size
        source_result_rejections_count_after = source_results.select(&:rejected?).size
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

      def find_or_create_event_category(source_result)
        return event_categories.first unless categories?

        category = source_result.category.best_match_in(event_categories.map(&:category))
        event_category = event_categories.find { |c| c.category == category }

        return event_category if event_category

        event_category = Models::EventCategory.new(source_result.event_category.category)
        event_category.reject "not_calculation_category"
        event_categories << event_category

        event_category
      end

      def in_calculation_category?(source_result)
        return true unless categories?

        source_result.category.best_match_in(categories).present?
      end

      def map_source_results_to_results(source_results)
        source_results.each do |source_result|
          source_result_in_calculation_category = in_calculation_category?(source_result)
          unless source_result_in_calculation_category
            source_result.reject "not_calculation_category"
          end

          event_category = find_or_create_event_category(source_result)

          calculated_result = event_category.results.find { |r| r.participant.id == source_result.participant.id }
          if calculated_result
            calculated_result.source_results << source_result
          else
            calculated_result = Models::CalculatedResult.new(
              Models::Participant.new(source_result.participant.id, membership: source_result.participant.membership),
              [source_result]
            )
            unless source_result_in_calculation_category
              calculated_result.reject "not_calculation_category"
            end

            event_category.results << calculated_result
          end
        end
      end

      def results
        event_categories.flat_map(&:results)
      end

      def source_results
        results.flat_map(&:source_results)
      end

      def unrejected_results
        results.reject(&:rejected?)
      end

      def unrejected_source_results
        source_results.reject(&:rejected?)
      end

      def validate!
        if event_categories.size != event_categories.uniq.size
          raise("Duplicate categories in #{event_categories.map(&:name).sort}")
        end
      end

      delegate :categories, :categories?, :team?, to: :rules
    end
  end
end
