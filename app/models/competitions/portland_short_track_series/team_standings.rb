module Competitions
  module PortlandShortTrackSeries
    class TeamStandings < Competition
      include PortlandShortTrackSeries::Common

      validates_presence_of :parent
      after_create :add_source_events
      before_create :set_name

      def self.calculate!(year = Time.zone.today.year)
        ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
          transaction do
            series = WeeklySeries.where(name: parent_event_name).year(year).first

            if series && series.any_results_including_children?
              team_competition = series.child_competitions.detect { |c| c.is_a? TeamStandings }
              unless team_competition
                team_competition = self.new(parent_id: series.id)
                team_competition.save!
              end
              team_competition.set_date
              team_competition.delete_races
              team_competition.create_races
              team_competition.calculate!
            end
          end
        end
        true
      end

      def set_name
        self.name = "Team Competition"
      end

      def race_category_names
        [ "Team" ]
      end

      def team?
        true
      end

      def members_only?
        false
      end

      def source_events?
        true
      end

      def use_source_result_points?
        true
      end

      def maximum_events(race)
        6
      end

      # Unique reshuffling of results for this competition before calculation
      def after_source_results(results, race)
        # Partition by event and apply all below:
        # Partition results into categories based on participant age and source result gender
        # - M/F: 10-14, 15-18, 19-34, 35-44, 45-54, 55+
        # - infer age from category if there is no participant age
        # Sort by ability category, then by place
        # reject bottom 10% from each category except the "lowest" (Cat 3s)
        # assign points from 0-100 by 100 * ( n - p + 1 ) / n where n = age/gender category size and p = place
        # rules say: select top 4 team results (should be handled by results_per_event),
        #   though … based on last year's results,
        #   it looks like we're taking top-4 in each category
        # refactor: after partitioning, each partition can be transformed independently
        # refactor: can remove results = bits now

        source_event_ids(race).map do |event_id|
          _results = results.select { |r| r["event_id"] == event_id }

          _results = _results.map do |r|
            if r["category_name"] == "Clydesdale"
              r["category_ability"] = 2
            end
            if r["category_name"] == "Singlespeed"
              r["category_ability"] = 0
            end
            r
          end

          _results = partition_results_by_age_and_gender(_results)
          _results = sort_results_by_ability_category_and_place(_results)
          _results = reject_worst_results(_results)
          _results = add_points(_results)
          _results = take_top_4(_results)
          _results.values.flatten
        end.
        flatten
      end

      def partition_results_by_age_and_gender(results)
        partitioned_results = Hash.new { |h, k| h[k] = [] }

        results.each do |result|
          category = partition_category_for(result)
          raise("No category found for #{result}") unless category
          partitioned_results[category] << result
        end

        partitioned_results
      end

      def partition_category_for(result)
        partition_categories.detect do |category|
          gender = result["gender"] || result["person_gender"] || "M"

          age = result["age"] || result["category_ages_begin"]
          if age == 0
            age = 19
          end

          ages_begin = category.ages_begin
          if ages_begin == 0
            ages_begin = 19
          end

          ages_begin <= age &&
          category.ages_end   >= age &&
          category.gender     == gender
        end
      end

      def partition_categories
        @partition_categories ||= find_or_create_partition_categories
      end

      def find_or_create_partition_categories
        %w{ Men Women }.map do |gender|
          [ "10-14", "15-18", "19-34", "35-44", "45-54", "55+" ].map do |ages|
            Category.find_or_create_by_normalized_name("#{gender} #{ages}")
          end
        end.
        flatten
      end

      def sort_results_by_ability_category_and_place(results)
        sorted_results = Hash.new
        results.each do |category, category_results|
          sorted_results[category] = sort_by_ability_category_and_place(category_results)
        end
        sorted_results
      end

      def sort_by_ability_category_and_place(results)
        results.sort do |x, y|
          diff = x["category_ability"] <=> y["category_ability"]

          if diff == 0
            numeric_place(x) <=> numeric_place(y)
          else
            diff
          end
        end
      end

      # Similar methods work on object attributes, not hash values
      def numeric_place(result)
        if result["place"] && result["place"].to_i > 0
          result["place"].to_i
        else
          Float::INFINITY
        end
      end

      def reject_worst_results(results)
        filtered_results = Hash.new
        results.each do |category, category_results|
          filtered_results[category] = reject_worst_category_results(category_results)
        end
        filtered_results
      end

      def reject_worst_category_results(results)
        results.
        group_by { |r| r["category_ability"] }.
        map do |category_ability, category_results|
          if category_ability < 3
            category_results[ 0, (category_results.size * 0.9).ceil ]
          else
            category_results
          end
        end.
        flatten
      end

      def add_points(results)
        results_with_points = Hash.new
        results.each do |category, category_results|
          results_with_points[category] = add_category_points(category_results)
        end
        results_with_points
      end

      def add_category_points(results)
        results.map.with_index do |result, index|
          place = index + 1
          result["points"] = 100.0 * ((results.size - place) + 1) / results.size
          result
        end
      end

      def take_top_4(results)
        top_results = Hash.new
        results.each do |category, category_results|
          top_results[category] = take_top_4_in_category(category_results)
        end
        top_results
      end

      def take_top_4_in_category(results)
        results.
        group_by { |r| r["participant_id"] }.
        map do |participant_id, participant_results|
          [ participant_id, participant_results[0, 4] ]
        end.
        map(&:last).
        flatten
      end
    end
  end
end
