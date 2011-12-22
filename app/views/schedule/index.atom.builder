# FIXME Add promoter contact info
atom_feed do |feed|
  feed.title "#{RacingAssociation.current.name} #{@year} Schedule"
  now = Time.zone.now.beginning_of_day.to_date
  events = @events.select { |e| e.flyer.present? && e.flyer_approved? && e.date >= now }
  feed.updated events.map(&:updated_at).max

  events.each do |event|
    url = nil
    if event.flyer.present? && event.flyer_approved?
      url = event.flyer
    end

    feed.entry(event, :url => url) do |entry|
      entry.title event.full_name
      entry.content "#{event.discipline} #{event.city_state}"
    end
  end
end
