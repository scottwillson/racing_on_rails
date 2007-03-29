#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/boot'
require 'commands/runner'

bar = Bar.find_by_date(Date.new(2007, 1, 1))

bar.standings.select {|standings| 
  standings.name != 'Overall' and standings.name != 'Team'
}
puts("Standings: #{bar.standings.size}")

standings = bar.standings.sort_by {|s| s.name}


standings.each {|s|
  puts(s.name)
  puts("Races: #{s.races.size}")
  races = s.races.sort_by {|race| race.name}
  races.each {|race|
    puts(race.name)
    puts("Results: #{race.results.size}")
    race.results.sort!
    race.results.each {|result|
      puts("#{result.place} #{result.name} #{result.team_name} #{result.points}")
    }
  }
}