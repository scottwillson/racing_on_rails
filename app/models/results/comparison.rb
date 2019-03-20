# frozen_string_literal: true

module Results
  module Comparison
    extend ActiveSupport::Concern

    # For competition result equivalence. Don't want to override hash and eql? for all Results.
    def competition_result_hash
      (
        person_id.hash ^
        (person_name.hash * 2) ^
        (place.hash * 3) ^
        (points.hash * 5) ^
        (team_id.hash * 7) ^
        (team_name.hash * 11)
      ).hash
    end

    # Highest points first. Break ties by highest placing
    # OBRA rules:
    # * The most first place finishes or, if still tied, the most second place finishes, etc., or if still tied;
    # * The highest placing in the last race, or the race nearest the last race in which at least one of the tied riders placed.
    #
    # Fairly complicated and procedural, but in nearly all cases, it short-circuits after comparing points
    def compare_by_points(other, break_ties = true)
      diff = other.points <=> points
      return diff if diff != 0 || !break_ties

      diff = compare_by_highest_place(other)
      return diff if diff != 0

      diff = compare_by_most_recent_place(other)
      return diff if diff != 0

      0
    end

    def compare_by_time(other, break_ties = true)
      diff = other.time <=> time
      return diff if diff != 0 || !break_ties

      diff = compare_by_highest_place(other)
      return diff if diff != 0

      diff = compare_by_most_recent_place(other)
      return diff if diff != 0

      0
    end

    def compare_by_highest_place(other)
      scores_by_place = scores.sort_by(&:source_result)
      other_scores_by_place = other.scores.sort_by(&:source_result)
      max_results = [scores_by_place.size, other_scores_by_place.size].max
      return 0 if max_results == 0
      for index in 0..(max_results - 1)
        if scores_by_place.size == index
          return 1
        elsif other_scores_by_place.size == index
          return -1
        else
          diff = scores_by_place[index].source_result.place <=> other_scores_by_place[index].source_result.place
          return diff if diff != 0
        end
      end
      0
    end

    def compare_by_most_recent_place(other)
      dates = Set.new(scores + other.scores) { |score| score.source_result.date }.to_a
      dates.sort!.reverse!
      dates.each do |date|
        score = scores.detect { |s| s.source_result.event.date == date }
        other_score = other.scores.detect { |s| s.source_result.event.date == date }
        if score && !other_score
          return -1
        elsif !score && other_score
          return 1
        else
          diff = score.source_result.place <=> other_score.source_result.place
          return diff if diff != 0
        end
      end
      0
    end

    # Poor name. For comparison, we sort by placed, finished, DNF, etc
    # Rejected calculation results are last
    def major_place
      if numeric_place?
        0
      elsif rejected?
        5
      elsif place.blank? || place == 0
        1
      elsif place.casecmp("DNF").zero?
        2
      elsif place.casecmp("DQ").zero?
        3
      elsif place.casecmp("DNS").zero?
        4
      else
        6
      end
    end

    # All numbered places first, then blanks, followed by DNF, DQ, and DNS
    def <=>(other)
      # Respect eql?
      return 0 if id.present? && (id == other&.id)

      # Figure out the major position by place first, then break it down further if needed
      major_difference = (major_place <=> other.major_place)
      if major_difference != 0
        return major_difference
      end

      if rejected? && other.rejected?
        if last_name == other.last_name
          return (first_name || "") <=> (other.first_name || "")
        else
          return (last_name || "") <=> (other.last_name || "")
        end
      end

      if numeric_place?
        return numeric_place <=> other.numeric_place
      elsif id.present?
        return id <=> other.id
      end

      0
    end
  end
end
