class CallupEvent
  attr_accessor :event_id
  attr_accessor :depth

  def initialize(event_id, depth = 3)
    @event_id = event_id
    @depth = depth
  end
end

CSV.open("callups.csv", "wb") do |csv|
  csv << [
    "event_id",
    "event_date",
    "event_name",
    "race_id",
    "race_name",
    "result_id",
    "place",
    "person_id",
    "name",
    "team_name",
    "license"
  ]

  [
    CallupEvent.new(26440, 10),
    CallupEvent.new(27090),
    CallupEvent.new(27097),
    CallupEvent.new(27105),
    CallupEvent.new(27093),
    CallupEvent.new(27106),
    CallupEvent.new(27104)
  ].each do |callup_event|
    places = %w{ 1 2 3 }
    if callup_event.depth == 10
      places = %w{ 1 2 3 4 5 6 7 8 9 10 }
    end
    event = Event.include_results.where("results.place": places).references(:results).find(callup_event.event_id)
    event.races.each do |race|
      race.results.sort.each do |result|
        csv << [
          event.id,
          event.date,
          event.full_name,
          race.id,
          race.name,
          result.id,
          result.place,
          result.person_id,
          result.name,
          result.team_name,
          result.person.license
        ]
      end
    end
  end
end
