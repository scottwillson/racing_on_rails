# Year-long OBRA TT competition
class OregonTTCup < Competition
  include Concerns::Competition::CalculatorAdapter

  def friendly_name
    'Oregon Time Trial Cup'
  end

  def category_names
    [ "Junior Men 10-12",
      "Junior Men 13-14",
      "Junior Men 15-16",
      "Junior Men 17-18", 
      "Junior Women 10-14", 
      "Junior Women 15-18", 
      "Senior Men Pro/1/2", 
      "Category 3 Men",
      "Category 4/5 Men",
      "Masters 30+", 
      "Masters 40+", 
      "Masters 50+", 
      "Masters 60+", 
      "Senior Women 1/2", 
      "Category 3 Women", 
      "Category 4/5 Women", 
      "Eddy Senior Men", 
      "Eddy Senior Women" ]
  end

  def point_schedule
    [ 0, 20, 17, 15, 13, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
  end

  def all_year?
    false
  end

  def source_results(race)
    query = Result.
      select([
        "results.id as id", "person_id as participant_id", "people.member_from", "people.member_to", "place", "results.event_id", "race_id", "events.date", "results.year", 
        "coalesce(races.bar_points, events.bar_points, parents_events.bar_points, parents_events_2.bar_points) as multiplier"
      ]).
      joins(:race => :event).
      joins("left outer join people on people.id = results.person_id").
      joins("left outer join events parents_events on parents_events.id = events.parent_id").
      joins("left outer join events parents_events_2 on parents_events_2.id = parents_events.parent_id").
      where("place between 1 and ?", point_schedule.size).
      where("(events.type in (?) or events.type is NULL)", source_event_types).
      where(:bar => true).
      where("races.category_id in (?)", category_ids_for(race)).
      where("events.sanctioned_by" => RacingAssociation.current.default_sanctioned_by).
      where("events.discipline in (:disciplines)
            or (events.discipline is null and parents_events.discipline in (:disciplines))
            or (events.discipline is null and parents_events.discipline is null and parents_events_2.discipline in (:disciplines))", 
            :disciplines => disciplines_for(race)).
      where("coalesce(races.bar_points, events.bar_points, parents_events.bar_points, parents_events_2.bar_points) > 0").
      where("results.year = ?", year)

    Result.connection.select_all query
  end
end
