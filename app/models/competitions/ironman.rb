module Competitions
  # Who has done the most events? Just counts starts/appearences in results. Not pefect -- some events
  # are probably over-counted.
  # TODO Don't replace existing results
  class Ironman < Competition
    include Competitions::Calculations::CalculatorAdapter

    def friendly_name
      'Ironman'
    end

    def points_for(source_result)
      1
    end

    def break_ties?
      false
    end

    def dnf?
      true
    end

    def notes
      "The Ironman Competition is a 'just for fun' record of the number of events riders do. There is no prize just identification of riders who need to get a life."
    end

    # Results as array of hashes. Select fewest fields needed to calculate results.
    # Some competition rules applied here in the query and results excluded. It's a judgement call to apply them here
    # rather than in #calculate.
    def source_results(race)
      query = Result.
        select(["results.id as id", "person_id as participant_id", "people.member_from", "people.member_to", "place", "results.event_id", "race_id", "events.date", "year"]).
        joins(:race, :event, :person).
        where("races.category_id is not null").
        where("events.type = 'SingleDayEvent' or events.type = 'Event' or events.type is null").
        where("events.ironman = true").
        where("results.year = ?", year)

      Result.connection.select_all query
    end
  end
end
