# require "csv"

interval = Result.count / 1000
index = 0
#
# CSV.open("results.csv", "w") do |csv|
#   csv << %w{ result_id event_id event_name event_city event_state event_date race_id race_name person_id person_name team_id team_name place points number age city }
#   Result.find_each do |result|
#     index = index + 1
#     putc(".") if index % interval == 0
#     csv << [
#       result.id,
#       result.event_id,
#       result.event.name,
#       result.event.city,
#       result.event.state,
#       result.event.date,
#       result.race_id,
#       result.race_name,
#       result.person_id,
#       result.name,
#       result.team_id,
#       result.team_name,
#       result.place,
#       result.points,
#       result.number,
#       result.age,
#       result.city
#     ]
#   end
# end


client = Mongo::Connection.new
db     = client['results']
coll   = db['results']

query = Result.
  select(
    "distinct results.id as id",
    "1 as multiplier",
    "competition_events.type",
    "events.bar_points as event_bar_points",
    "events.date",
    "events.type",
    "member_from",
    "member_to",
    "parents_events.bar_points as parent_bar_points",
    "parents_events_2.bar_points as parent_parent_bar_points",
    "races.bar_points as race_bar_points",
    "results.event_id",
    "results.person_id",
    "results.team_id",
    "place",
    "results.points",
    "results.race_id",
    "results.race_name as category_name",
    "results.year",
    "scores.points as points",
    "team_member",
    "team_name"
  ).
  joins(:race, :event, :person).
  joins("left outer join events parents_events on parents_events.id = events.parent_id").
  joins("left outer join events parents_events_2 on parents_events_2.id = parents_events.parent_id").
  joins("join scores on scores.source_result_id = results.id").
  joins("join results as competition_results on competition_results.id = scores.competition_result_id").
  joins("join events as competition_events on competition_events.id = competition_results.event_id")

Result.connection.select_all(query).each do |result|
  result["date"] = result["date"].to_time if result["date"]
  result["member_from"] = result["member_from"].to_time if result["member_to"]
  result["member_to"] = result["member_to"].to_time if result["member_from"]
  # result.each do |k,v|
  #   puts "#{k} #{v.class}"
  # end
  index = index + 1
  putc(".") if index % interval == 0
  coll.insert result
end