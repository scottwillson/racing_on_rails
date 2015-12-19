module Events
  module Previous
    extend ActiveSupport::Concern

    def previous?
      previous.present?
    end

    def previous
      exact_match = Event.find_by(name: name, year: year - 1)
      return exact_match if exact_match

      diff, event = previous_best_match
      return unless event
      return event if diff <= 2
      return event if similar_promoter_name?(event)
      return event if diff < 5 && similar_dates?(event)
    end

    # return diff (0 = perfect match, > 0 partial match), event
    def previous_best_match
      match = previous_year_events_with_similar_names.first
      [ match.try(:first), match.try(:last).try(:first) ]
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

    def similar_promoter_name?(event)
      event.promoter_name &&
        promoter_name &&
        DamerauLevenshtein.distance(event.promoter_name, promoter_name)  <= 3
    end

    def similar_dates?(event)
      ((event.date.month * 12 + event.date.day) - (date.month * 12 + date.day)).abs < 10
    end
  end
end
