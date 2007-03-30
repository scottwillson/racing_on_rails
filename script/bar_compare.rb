#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../config/environment'

if ARGV[0] == 'expected'
  bar = Bar.find_by_date(Date.new(2007, 1, 1))
elsif ARGV[1] == 'Overall'
  bar = OverallBar.find_by_date(Date.new(2007, 1, 1))  
elsif ARGV[1] == 'Team'
  bar = TeamBar.find_by_date(Date.new(2007, 1, 1))
else
  bar = Bar.find_by_date(Date.new(2007, 1, 1))
end  

if ARGV[1] == 'Overall'
  standings = bar.standings.select {|standings| 
    standings.name['Overall']
  }
elsif ARGV[1] == 'Team'
  standings = bar.standings.select {|standings| 
    standings.name['Team']
  }
else
  standings = bar.standings.select {|standings| 
    standings.name != 'Overall' and standings.name != 'Team'
  }
end
puts("Standings: #{standings.size}")

standings = standings.sort_by {|s| s.name}
standings.each {|s|
  puts(s.name)
  puts("Races: #{s.races.size}")
  races = s.races.sort_by {|race| race.name}
  races.each {|race|
    puts(race.name)
    puts("Results: #{race.results.size}")
    race.results.sort{|x, y|
      diff = x.place <=> y.place
      if diff == 0
        diff = x.racer <=> y.racer
      end
      if diff == 0
        diff = x.team <=> y.team
      end
      diff
    }
    race.results.each {|result|
      if ARGV[2] == 'team'
        puts("#{result.place} #{result.name} #{result.team_name} #{result.points}")
      else
        puts("#{result.place} #{result.name} #{result.points}")
      end
    }
  }
}