Event.
where("MONTH(date) = 1 and DAY(date) = 1").each do |event|
  if event.respond_to?(:set_date)
    puts "#{event.date} #{event.set_date} #{event.full_name} #{event.type} (#{event.source_events.size}) all_year? #{event.all_year?}"
    event.save!
  elsif event.parent
    puts "#{event.date} #{event.parent.date} #{event.full_name} #{event.type} (#{event.parent.try :name})"
    event.start_date = event.parent.date
    event.save!
  end
end
