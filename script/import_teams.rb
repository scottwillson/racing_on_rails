#!/usr/bin/env ruby -wKU

Team.transaction do
  File.new("teams2.txt").readlines.each do |line|
    cells = line.split("\t")
    cells.each { |cell| cell.strip! }
    p "*" * 80
    p cells[0]
    p cells[1]
    p cells[2]
    p cells[3]
    p "-" * 80

    website = cells[0][/href="(.*)"/, 1]
    p "website: #{website}"

    if website == "" || website.nil?
      name = cells[0]
    else
      name = cells[0][/href="(.*)">([^<]+)/, 2]
    end
    p "name: #{name}"

    sponsors = cells[1]
    p "sponsors: #{sponsors}"
  
    contact_email = cells[2][/href="mailto:(.*)"/, 1]
    p "contact_email: #{contact_email}"
    if contact_email == "" || contact_email.nil?
      contact_name = cells[2]
    else
      contact_name = cells[2][/href="mailto:(.*)">([^<]+)/, 2]
    end
    p "contact_name: #{contact_name}"

    contact_phone = cells[3]
    p "contact_phone: #{contact_phone}"
  
    team = Team.find_by_name_or_alias(name)
    raise "#{name} not found" unless team
    
    team.website = website unless website.blank?
    team.sponsors = sponsors unless sponsors.blank?
    team.contact_name = contact_name unless contact_name.blank?
    team.contact_email = contact_email unless contact_email.blank?
    team.contact_phone = contact_phone unless contact_phone.blank?
    team.save!
  end
end