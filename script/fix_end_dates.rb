Event.transaction do
  Event.all.each do |event|
    old_end_date = event.end_date

    case event
    when MultiDayEvent
      event.update_date
    else
      if event.date != event.end_date
        event.end_date = event.date
        event.save!
      end
    end

    if event.end_date != old_end_date
      puts "#{event.date} #{event.full_name} changed end date from #{old_end_date} to #{event.end_date}"
    end
  end
end
