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
      include Calculations::V3::Calculators::Categories

      attr_reader :calculations_events
      attr_reader :event_categories
      attr_reader :rules
      attr_reader :source_events
      attr_reader :year

      def initialize(calculations_events: [], logger: Logger.new(STDOUT, level: :fatal), rules: Rules.new, source_events: [], source_results: [], year: Date.today.year)
        raise(ArgumentError, "rules should be Rules, but are #{rules.class}") unless rules.is_a?(Rules)

        @calculations_events = calculations_events
        @logger = logger
        @rules = rules
        @source_events = source_events
        @year = year

        @event_categories = create_event_categories
        map_source_results_to_results source_results
      end

      # Do the work, all in memory with Ruby classes
      def calculate!
        @logger.debug "Calculator#calculate! source_results: #{source_results.size} rules: #{rules.to_h}"

        if rules.place_by == "place"
          # place before assigning points
          calculate_step(Steps::RejectCalculatedEvents)
            .calculate_step(Steps::RejectWeekdayEvents)
            .calculate_step(Steps::SelectInDiscipline)
            .calculate_step(Steps::RejectCategories)
            .calculate_step(Steps::AssignTeamSizes)
            .calculate_step(Steps::RejectNoParticipant)
            .calculate_step(Steps::SelectAssociationSanctioned)
            .calculate_step(Steps::SelectMembers)
            .calculate_step(Steps::RejectDnfs)
            .calculate_step(Steps::RejectBelowMinimumEvents)
            .calculate_step(Steps::RejectMoreThanResultsPerEvent)
            .calculate_step(Steps::RejectCategoryWorstResults)
            .calculate_step(Steps::RejectEmptySourceResults)
            .calculate_step(Steps::RejectAllSourceResultsRejected)
            .calculate_step(Steps::Place)
            .calculate_step(Steps::AssignPoints)
            .calculate_step(Steps::AddMissingResultsPenalty)
            .calculate_step(Steps::RejectMoreThanMaximumEvents)
            .calculate_step(Steps::SumPoints)
            .calculate_step(Steps::Validate)
            .calculate_step(Steps::RejectEmptyCategories)
            .event_categories
        else
          # place after assigning points
          calculate_step(Steps::RejectCalculatedEvents)
            .calculate_step(Steps::RejectWeekdayEvents)
            .calculate_step(Steps::SelectInDiscipline)
            .calculate_step(Steps::RejectCategories)
            .calculate_step(Steps::AssignTeamSizes)
            .calculate_step(Steps::RejectNoParticipant)
            .calculate_step(Steps::SelectAssociationSanctioned)
            .calculate_step(Steps::SelectMembers)
            .calculate_step(Steps::RejectDnfs)
            .calculate_step(Steps::RejectBelowMinimumEvents)
            .calculate_step(Steps::RejectMoreThanResultsPerEvent)
            .calculate_step(Steps::RejectCategoryWorstResults)
            .calculate_step(Steps::AssignPoints)
            .calculate_step(Steps::AddMissingResultsPenalty)
            .calculate_step(Steps::RejectMoreThanMaximumEvents)
            .calculate_step(Steps::RejectEmptySourceResults)
            .calculate_step(Steps::RejectAllSourceResultsRejected)
            .calculate_step(Steps::SumPoints)
            .calculate_step(Steps::Place)
            .calculate_step(Steps::Validate)
            .calculate_step(Steps::RejectEmptyCategories)
            .event_categories
        end
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

      def map_source_results_to_results(source_results)
        source_results.each do |source_result|
          source_result_in_calculation_category = in_calculation_category?(source_result)
          source_result.reject("not_calculation_category") unless source_result_in_calculation_category

          event_category = find_or_create_event_category(source_result)
          calculated_result = find_calculated_result(event_category, source_result.participant.id)

          if calculated_result
            calculated_result.source_results << source_result
          else
            calculated_result = Models::CalculatedResult.new(
              Models::Participant.new(source_result.participant.id, membership: source_result.participant.membership),
              [source_result]
            )
            calculated_result.reject("not_calculation_category") unless source_result_in_calculation_category

            event_category.results << calculated_result
          end
        end
      end

      def find_calculated_result(event_category, participant_id)
        return nil if rules.place_by == "place" || rules.place_by == "time"

        event_category.results.find { |r| r.participant.id == participant_id }
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
        unrejected_results.flat_map(&:source_results).reject(&:rejected?)
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
