module Events
  module Competitions
    extend ActiveSupport::Concern

    included do
      has_many :child_competitions,
               -> { order :date },
               class_name: "Competitions::Competition",
               foreign_key: "parent_id",
               dependent: :destroy,
               after_add: :children_changed,
               after_remove: :children_changed

      has_one :overall, foreign_key: "parent_id", dependent: :destroy, class_name: "Competitions::Overall"
      has_one :combined_results, class_name: "CombinedTimeTrialResults", foreign_key: "parent_id", dependent: :destroy
      has_many :competitions, through: :competition_event_memberships, source: :competition, class_name: "Competitions::Competition"
      has_many :competition_event_memberships, class_name: "Competitions::CompetitionEventMembership"

      def self.find_all_bar_for_discipline(discipline, year = Time.zone.today.year)
        discipline_names = [discipline]
        discipline_names << 'Circuit' if discipline.downcase == 'road'
        Event.distinct.year(year).where(discipline: discipline_names).where("bar_points > 0")
      end
    end

    # Set point value/factor for this Competition. Convenience method to hide CompetitionEventMembership complexity.
    def set_points_for(competition, points)
      # For now, allow Nil exception, but probably will want to auto-create membership in the future
      competition_event_membership = competition_event_memberships.detect { |cem| cem.competition == competition }
      competition_event_membership.points_factor = points
      competition_event_membership.save!
    end

    def event_teams?
      false
    end

    # Only consider results from source_events. Default to false: use all events in year.
    def source_events?
      false
    end
  end
end
