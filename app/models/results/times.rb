# frozen_string_literal: true

module Results
  module Times
    extend ActiveSupport::Concern

    def time=(value)
      self[:time] = time_value(value)
    end

    def time_bonus_penalty=(value)
      self[:time_bonus_penalty] = time_value(value)
    end

    def time_gap_to_leader=(value)
      self[:time_gap_to_leader] = time_value(value)
    end

    def time_total=(value)
      self[:time_total] = time_value(value)
    end

    def time_gap_to_previous=(value)
      self[:time_gap_to_previous] = time_value(value)
    end

    def time_gap_to_winner=(value)
      self[:time_gap_to_winner] = time_value(value)
    end

    def time_total=(value)
      self[:time_total] = time_value(value)
    end

    def time_value(value)
      case value
      when DateTime, ::Time
        value = value.hour * 3600 + value.min * 60 + value.sec + (value.usec / 100.0)
      when Numeric, NilClass
        value
      else
        value = s_to_time(value)
      end

      value = value.round(3) if value

      value
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    def time_s
      time_to_s(time)
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    def time_s=(time)
      self.time = s_to_time(time)
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    def time_total_s
      time_to_s(time_total)
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    def time_total_s=(time_total)
      self.time_total = s_to_time(time_total)
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    def time_bonus_penalty_s
      time_to_s(time_bonus_penalty)
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    def time_bonus_penalty_s=(time_bonus_penalty)
      self.time_bonus_penalty = s_to_time(time_bonus_penalty)
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    def time_gap_to_leader_s
      time_to_s(time_gap_to_leader)
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    def time_gap_to_leader_s=(time_gap_to_leader_s)
      self.time_gap_to_leader = s_to_time(time_gap_to_leader_s)
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    def time_gap_to_winner_s
      time_to_s time_gap_to_winner
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    # This method doesn't handle some typical edge cases very well
    def time_to_s(time)
      return "" if time == 0.0 || time.blank?

      positive = time >= 0

      time = -time unless positive

      hours = (time / 3600).to_i
      minutes = ((time - (hours * 3600)) / 60).floor
      seconds = (time - (hours * 3600).floor - (minutes * 60).floor)
      seconds = format("%0.2f", seconds)
      hour_prefix = "#{hours.to_s.rjust(2, '0')}:" if hours > 0
      "#{'-' unless positive}#{hour_prefix}#{minutes.to_s.rjust(2, '0')}:#{seconds.rjust(5, '0')}"
    end

    # Time in hh:mm:ss.00 format. E.g., 1:20:59.75
    # This method doesn't handle some typical edge cases very well
    def s_to_time(string)
      if string.to_s.blank? || !string.to_s[/\d/]
        nil
      else
        string = string.tr(",", ".")
        parts = string.to_s.split(":").reverse
        t = 0.0
        parts.each_with_index do |part, index|
          t += part.to_f * (60.0**index)
        end
        if parts.last&.starts_with?("-")
          -t
        else
          t
        end
      end
    end
  end
end
