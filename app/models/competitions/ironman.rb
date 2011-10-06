# Who has done the most events? Just counts starts/appearences in results. Not pefect -- some events
# are probably over-counted.
class Ironman < Competition
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
  
  def source_results(race)
    Result.
      joins(:race, :event).
      where("place != 'DNS'").
      where("races.category_id is not null").
      where("events.type = 'SingleDayEvent' or events.type is null").
      where("events.ironman = true").
      where("results.date between ? and ?", Time.zone.local(year).beginning_of_year, Time.zone.local(year).end_of_year).
      order("person_id")
  end
end
