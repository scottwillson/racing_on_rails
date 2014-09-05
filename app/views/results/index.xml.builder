xml.instruct!
cache [ @year, @today, @discipline, RacingAssociation.current.updated_at, false ] do
  xml.events do
    (@all_events).each do |event|
      xml.event do
        xml.id event.id
        xml.name event.full_name
        xml.date event.date
      end
    end
  end
end
