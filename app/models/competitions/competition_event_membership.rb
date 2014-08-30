module Competitions
  # Link Competition to source_events Events.
  # +points_factor+ Points multiplier for source event. Usually 0, 1, 2, 3. 0 excludes source event.
  class CompetitionEventMembership < ActiveRecord::Base
    validates_uniqueness_of :event_id, scope: :competition_id

    belongs_to :competition
    belongs_to :event
  end
end
