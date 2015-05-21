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

      def source_events?
        true
      end

      def results_per_event
        4
      end

      def maximum_events(race)
        6
      end

      # Unique reshuffling of results for this competition
      def after_source_results(results, race)
        results = select_source_event_results(results, race)

        # Partition results into categories based on participant age and source result gender
        # - M/F: 10-14, 15-18, 19-34, 35-44, 45-54, 55+
        # - infer age from category if there is no participant age
        # Sort by ability category, then by place
        # reject bottom 10% from each category except the "lowest" (Cat 3s)
        # assign points from 0-100 by 100 * ( n - p + 1 ) / n where n = age/gender category size and p = place
        # select top 4 team results (should be handled by results_per_event), though … based on last year's results,
        #   it looks like we're taking top-4 in each category

        results
      end

      def select_source_event_results(results, race)
        source_event_ids = source_event_ids(race)
        results.select { |r| r["event_id"].in?(source_event_ids) }
      end
    end
  end
end
