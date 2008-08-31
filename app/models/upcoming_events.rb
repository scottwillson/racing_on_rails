module UpcomingEvents
  # UpcomingEvents needs methods on Discipline, but logic is more about upcoming events

  def UpcomingEvents.find_all(*conditions)
    conditions_hash = conditions.extract_options!
    upcoming_events = UpcomingEvents::Base.new(conditions_hash[:date], conditions_hash[:weeks], conditions_hash[:discipline])
    upcoming_events.disciplines.each do |discipline|
      discipline.upcoming_events = discipline.find_all_upcoming_events(upcoming_events.dates)
      discipline.upcoming_weekly_series = discipline.find_all_upcoming_weekly_series(upcoming_events.dates)
    end
    upcoming_events.disciplines.delete_if { |discipline| discipline.upcoming_events.empty? && discipline.upcoming_weekly_series.empty? }
    upcoming_events
  end
end
