# frozen_string_literal: true

module Results
  module Competitions
    extend ActiveSupport::Concern

    included do
      has_many :scores,
               class_name: "Competitions::Score",
               foreign_key: "competition_result_id",
               dependent: :destroy,
               extend: Results::CreateIfBestResultForRaceExtension
      has_many :dependent_scores, class_name: "Competitions::Score", foreign_key: "source_result_id", dependent: :destroy

      scope :competition, -> { where(competition_result: true) }
    end

    def update_points!
      calculate_points
      update_column :points, points if points_changed?
    end

    # Set points from +scores+
    def calculate_points
      # Drop to SQL for effeciency
      self.points = ::Competitions::Score.where(competition_result_id: id).sum(:points) if competition_result?
      points
    end

    def calculate_competition_result
      if frozen?
        self[:competition_result] || event.is_a?(::Competitions::Competition)
      else
        self[:competition_result] ||= event.is_a?(::Competitions::Competition)
      end
    end

    def calculate_team_competition_result
      if frozen?
        self[:team_competition_result] ||
          event.is_a?(::Competitions::TeamBar) ||
          event.is_a?(::Competitions::CrossCrusadeTeamCompetition) ||
          event.is_a?(::Competitions::MbraTeamBar)
      else
        self[:team_competition_result] ||= begin
          event.is_a?(::Competitions::TeamBar) ||
            event.is_a?(::Competitions::CrossCrusadeTeamCompetition) ||
            event.is_a?(::Competitions::MbraTeamBar)
        end
      end
    end
  end
end
