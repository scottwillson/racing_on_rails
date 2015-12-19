module Events
  module Previous
    extend ActiveSupport::Concern

    def previous?
      previous.present?
    end

    def previous
      exact_match = Event.find_by(name: name, year: year - 1)
      return exact_match if exact_match

      diff = previous_year_events_with_similar_names.first.try(:first)
      event = previous_year_events_with_similar_names.first.try(:last).try(:first)
      return unless event
      return event if diff <= 2

      if event.promoter_name && promoter_name && DamerauLevenshtein.distance(event.promoter_name, promoter_name) <= 3
        return event
      end

      return event if diff < 5 && ((event.date.month * 12 + event.date.day) - (date.month * 12 + date.day)).abs < 10
    end

    def previous_year_events_with_similar_names
      Event.where(year: year - 1).group_by { |e| DamerauLevenshtein.distance(name, e.name) }.sort_by(&:first)
    end

    def add_races_from_previous_year
      categories = races.map(&:category)

      previous.races
        .map(&:category)
        .reject { |c| c.in? categories }
        .each { |c| races.create! category: c }
    end
  end
end
