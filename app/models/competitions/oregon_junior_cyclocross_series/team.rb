# frozen_string_literal: true

module Competitions
  module OregonJuniorCyclocrossSeries
    class Team < Competition
      def point_schedule
        (1..30).to_a.reverse
      end

      def friendly_name
        "Oregon Junior Cyclocross Team Series"
      end

      def create_slug
        "ojcs_team"
      end

      def event_teams?
        true
      end

      def members_only?
        false
      end

      def source_result_category_names
        [
          "Junior Men 1/2/3",
          "Junior Men 13-14 3/4/5",
          "Junior Men 15-16 3/4/5",
          "Junior Men 17-18 3/4/5",
          "Junior Men 9-12 3/4/5",
          "Junior Women 1/2/3",
          "Junior Women 13-14 3/4/5",
          "Junior Women 15-16 3/4/5",
          "Junior Women 17-18 3/4/5",
          "Junior Women 9-12 3/4/5"
        ]
      end

      def maximum_events(_race)
        4
      end

      def source_results_query(race)
        super
          .select("event_teams.team_id as participant_id")
          .joins("inner join event_team_memberships on event_team_memberships.person_id = results.person_id")
          .joins("inner join event_teams on event_teams.id = event_team_memberships.event_team_id")
          .where.not(member_from: nil)
          .where("year(member_from) <= ?", year)
          .where.not(member_to: nil)
          .where("year(member_to) >= ?", year)
          .where("event_teams.id" => event_teams_with_at_least_members)
      end

      def categories_for(_race)
        source_result_categories
      end

      def event_teams_with_at_least_members
        event_teams.includes(:event_team_memberships).select do |team|
          team.event_team_memberships.size >= 3
        end
      end

      def results_per_event
        3
      end

      def results_per_race
        Competition::UNLIMITED
      end

      def source_events?
        true
      end

      def team?
        true
      end
    end
  end
end
