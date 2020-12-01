# frozen_string_literal: true

module Competitions
  # Tie a Competition Result to its source Result from a SingleDayEvent, and holds the points earned for the Competition
  #
  # Example: John Walrod places 3rd in the Mudslinger Singlespeed race. This earns him points for both the Singlespeed BAR
  # and the Ironman:
  #
  # Singlespeed BAR Score
  # * points: 22
  # * source_result: 3rd, Mudslinger
  # * competition_result: 18th Singlespeed BAR
  #
  # Ironman Score
  # * points: 1
  # * source_result: 3rd, Mudslinger
  # * competition_result: 200th Ironman
  class Score < ApplicationRecord
    belongs_to :source_result, class_name: "Result"
    belongs_to :competition_result, class_name: "Result"

    # Intentionally validate ids. validates_presence_of :association causes it to load.
    # TODO Try :inverse to fix this
    validates :source_result_id, :competition_result_id, :points, presence: true
    validates :points, numericality: true

    before_save :cache_date

    def cache_date
      self[:date] = date || source_result.date
    end

    def discipline
      competition_result.race.discipline
    end

    def source_discipline
      source_result.try(:race).try(:discipline)
    end

    def inspect_debug
      "#<Competitions::Score #{id} #{source_result_id} #{source_result.event.full_name} #{source_result.race.name} #{competition_result_id} place: #{source_result.place} points: #{points}>"
    end

    # Compare by points
    def <=>(other)
      other.points <=> points
    end

    def to_s
      "#<Competitions::Score #{id} #{source_result_id} #{competition_result_id} #{points}>"
    end
  end
end
