# Who has done the most events? Just counts starts/appearences in results. Not pefect -- some events
# are probably over-counted.
# TODO Don't replace existing results
class Ironman < Competition
  include Concerns::Competition::CalculatorAdapter

  def friendly_name
    'Ironman'
  end

  def Ironman.years
    years = []
    results = connection.select_all(
      "select distinct extract(year from date) as year from events where type = 'Ironman'"
    )
    results.each do |year|
      years << year.values.first.to_i
    end
    years.sort.reverse
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
  
  # Results as array of hashes. Select fewest fields needed to calculate results.
  # Some competition rules applied here in the query and results excluded. It's a judgement call to apply them here
  # rather than in #calculate.
  def source_results(race)
    query = Result.
      select(["results.id as id", "person_id as participant_id", "people.member_from", "people.member_to", "place", "results.event_id", "race_id", "events.date", "year"]).
      joins(:race, :event, :person).
      where("place != 'DNS'").
      where("races.category_id is not null").
      where("events.type = 'SingleDayEvent' or events.type = 'Event' or events.type is null").
      where("events.ironman = true").
      where("results.year = ?", year)

    Result.connection.select_all query
  end
end
