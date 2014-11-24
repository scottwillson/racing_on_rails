module Competitions
  module Points
    extend ActiveSupport::Concern

    def point_schedule
      @point_schedule || nil
    end

    def point_schedule=(value)
      @point_schedule = value
    end

    def most_points_win?
      true
    end

    def double_points_for_last_event?
      false
    end

    def field_size_bonus?
      false
    end

    def default_bar_points
      0
    end

    # Use the recorded place with all finishers? Or only place with just Assoication member finishers?
    def place_members_only?
      false
    end

    # Only members can score points?
    def members_only?
      true
    end
  end
end
