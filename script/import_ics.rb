CSV.open("schedule.csv", "wb") do |csv|
  csv << %w( name date location promoter_name promoter_email discipline first_aid_provider )
  RiCal.parse_string(File.read("obra.ics"))
    .first
    .events
    .each do |ics_event|
      # puts
      # puts '-' * 160
      # puts ics_event.to_s

      end_date = ics_event.dtstart
      if (ics_event.dtend - ics_event.dtstart) > 1
        end_date = ics_event.dtend
      end

      description = ics_event.description.split('\n')
      description.each {|x| puts x}
      promoter = description.first && description.first.gsub("From: ", "")
      promoter_name = promoter[/\A([^<]+)/, 1].strip
      promoter_email = promoter[/<([^>]+)/, 1].strip

      first_aid = "no"
      first_aid_line = description.detect { |l| l[/First Aid/] }
      if first_aid_line && first_aid_line["Yes"].present?
        first_aid = "Needed"
      end

      discipline_line = description.detect { |l| l[/Discipline/] }
      discipline = discipline_line && discipline_line[/Discipline: (.*)/, 1]

      puts
      puts({
        name: ics_event.summary,
        start_date: ics_event.dtstart.to_s(:db),
        end_date: end_date.to_s(:db),
        location: ics_event.location,
        promoter_name: promoter_name,
        promoter_email: promoter_email,
        first_aid_provider: first_aid,
        discipline: discipline,
        notes: ics_event.description
      })

      (ics_event.dtstart..end_date).each do |day|
        csv << [
          ics_event.summary,
          day.to_s(:db),
          ics_event.location,
          promoter_name,
          promoter_email,
          discipline,
          first_aid,
          ics_event.description
        ]
      end
  end
end
