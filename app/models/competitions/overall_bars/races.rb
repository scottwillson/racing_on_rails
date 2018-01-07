# frozen_string_literal: true

module Competitions
  module OverallBars
    module Races
      extend ActiveSupport::Concern

      def find_race(discipline, category)
        event = if Discipline[:overall] == discipline
                  self
                else
                  children.detect { |e| e.discipline == discipline.name }
                end

        ::Race
          .where(event_id: event.id)
          .where(category_id: category.id)
          .includes(:results)
          .first
      end
    end
  end
end
