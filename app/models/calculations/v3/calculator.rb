# frozen_string_literal: true

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
#      * cycle through each source result, find best match event category, add or create calcuted result, add source result?
#   2. assign points
#   3. create upgrade results
#   4. assign points again? What is sequence for upgrades?
#   5. sum points
#   6. place results (skip zero-results?)
# many missing steps ...
class Calculations::V3::Calculator
  # categories/rules
  def initialize(categories)
    @categories = categories
  end

  # Do the work, all in memory with Ruby classes
  def calculate!(source_results)
    event_categories = map_categories_to_event_categories(@categories)
    event_categories = map_source_results_to_results(source_results, event_categories)
    event_categories = assign_points(event_categories)
    event_categories = sum_points(event_categories)
    place(event_categories)
  end

  def map_categories_to_event_categories(categories)
    categories.map do |category|
      Calculations::V3::Models::EventCategory.new(category)
    end
  end

  # This is very wrong
  def map_source_results_to_results(source_results, event_categories)
    # find best category match
    # create participant result
    # add source result to participant result

    source_results.each do |source_result|
      event_category = event_categories.first

      calculated_result = event_category.results.find { |r| r.participant.id == source_result.participant.id }
      if calculated_result
        calculated_result.source_results << source_result
      else
        event_category.results << Calculations::V3::Models::CalculatedResult.new(
          Calculations::V3::Models::Participant.new(source_result.participant.id),
          [source_result]
        )
      end
    end
  end

  def assign_points(event_categories)
    event_categories.each do |category|
      category.results.each do |result|
        result.source_results.each do |source_result|
          source_result.points = 100
        end
      end
    end
  end

  def sum_points(event_categories)
    event_categories.each do |category|
      category.results.each do |result|
        result.points = result.source_results.sum(&:points)
      end
    end
  end

  def place(event_categories)
    event_categories.each do |category|
      category.results.each do |result|
        result.place = "1"
      end
    end
  end
end
