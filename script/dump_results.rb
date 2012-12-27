require "csv"

interval = Result.count / 1000
index = 0

CSV.open("results.csv", "w") do |csv|
  csv << %w{ result_id event_id event_name event_city event_state event_date race_id race_name person_id person_name team_id team_name place points number age city }
  Result.find_each do |result|
    index = index + 1
    putc(".") if index % interval == 0
    csv << [ 
      result.id, 
      result.event_id, 
      result.event.name, 
      result.event.city, 
      result.event.state, 
      result.event.date, 
      result.race_id, 
      result.race_name, 
      result.person_id, 
      result.name, 
      result.team_id, 
      result.team_name, 
      result.place,
      result.points,
      result.number,
      result.age,
      result.city
    ]
  end
end

