# frozen_string_literal: true

year = Time.current.year

year = ENV["YEAR"].to_i if ENV["YEAR"]

events = Event.competition.year(year).includes(races: :category).all.order(:date, :name)

events.each do |competition|
  competition.races.sort_by(&:name).each do |race|
    puts "#{competition.full_name} #{race.name} #{race.results.count}"
  end
end

events.each do |competition|
  competition.races.sort_by(&:name).each do |race|
    puts "#{competition.full_name} #{race.name} #{race.results.sum(:points)}"
  end
end
