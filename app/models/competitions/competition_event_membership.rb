# frozen_string_literal: true

module Competitions
  # Link Competition to source_events Events.
  # +points_factor+ Points multiplier for source event. Usually 0, 1, 2, 3. 0 excludes source event.
  class CompetitionEventMembership < ApplicationRecord
    validates :event_id, uniqueness: { scope: :competition_id }

    belongs_to :competition
    belongs_to :event
  end
end
