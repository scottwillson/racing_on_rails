# frozen_string_literal: true

CSV.open("schedule.csv", "wb") do |csv|
  csv << %w[ name date location promoter_name promoter_email discipline first_aid_provider ]
  RiCal.parse_string(File.read("obra.ics"))
       .first
       .events
       .each do |ics_event|
    # puts
    # puts '-' * 160
    # puts ics_event.to_s

    end_date = ics_event.dtstart
    end_date = ics_event.dtend if (ics_event.dtend - ics_event.dtstart) > 1

    original_description = ics_event.description.split("-::~")[0]
    description = original_description.split("\n")

    next if description.size < 2

    # description.each { |x| puts x }

    promoter = description.first&.gsub("From: ", "")
    promoter_name = ""
    promoter_email = ""
    if promoter.present?
      begin
        promoter_name = promoter[/\A([^<]+)/, 1].strip
        promoter_email = promoter[/<([^>]+)/, 1].strip
      rescue StandardError => e
        puts "#{e}: Could not parse promoter name and email from #{promoter}"
      end
    end

    first_aid = "no"
    first_aid_line = description.detect { |l| l[/First Aid/] }
    first_aid = "Needed" if first_aid_line && first_aid_line["Yes"].present?

    discipline_line = description.detect { |l| l[/Discipline/] }
    discipline = discipline_line && discipline_line[/Discipline: (.*)/, 1]

    location = ics_event.location

    if location.blank?
      location_line = description.detect { |l| l[/Location/] }
      location = location_line && location_line[/Location: (.*)/, 1]
    end

    if location.present?
      location = location.gsub(", USA", "")
      location = location.gsub(/\d{5}/, "")
    end

    puts
    puts(
      name: ics_event.summary,
      start_date: ics_event.dtstart.to_s(:db),
      end_date: end_date.to_s(:db),
      location: location,
      promoter_name: promoter_name,
      promoter_email: promoter_email,
      first_aid_provider: first_aid,
      discipline: discipline,
      notes: original_description
    )

    (ics_event.dtstart..end_date).each do |day|
      csv << [
        ics_event.summary,
        day.to_s(:db),
        location,
        promoter_name,
        promoter_email,
        discipline,
        first_aid,
        original_description
      ]
    end
  end
end
