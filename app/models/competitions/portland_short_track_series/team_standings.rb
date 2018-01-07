# frozen_string_literal: true

module Competitions
  module PortlandShortTrackSeries
    class TeamStandings < Competition
      include Competitions::PortlandShortTrackSeries::Common

      validates :parent, presence: true

      after_create :add_source_events

      def self.calculate!(year = Time.zone.today.year)
        ActiveSupport::Notifications.instrument "calculate.#{name}.competitions.racing_on_rails" do
          transaction do
            series = WeeklySeries.where(name: parent_event_name).year(year).first

            if series&.any_results_including_children?
              team_competition = self.year(year).first
              unless team_competition
                team_competition = new(parent_id: series.id)
                team_competition.save!
              end
              team_competition.set_date
              team_competition.delete_races
              team_competition.create_races
              team_competition.calculate!
            end
          end
        end

        # Don't return the entire populated instance!
        true
      end

      def name
        "Team Competition"
      end

      def default_discipline
        "Short Track"
      end

      def team?
        true
      end

      def all_year?
        false
      end

      def source_events?
        true
      end

      def categories?
        false
      end

      def add_source_events
        parent.children.each do |source_event|
          source_events << source_event if source_event.name == parent_event_name
        end
      end

      def race_category_names
        ["Team Competition"]
      end
    end
  end
end
