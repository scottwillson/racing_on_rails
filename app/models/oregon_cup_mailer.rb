module ActionView
  class Base
    include ApplicationHelper
  end
end

# Send results and upcoming Oregon Cup emails
class OregonCupMailer < ActionMailer::Base
  def kickoff(today = Date.today)
    @subject    = 'Oregon Cup Starts This Weekend'
    @recipients = 'obra@list.obra.org'
    @from       = 'Scott Willson <scott@butlerpress.com>'
    date = Date.new(today.year, 1, 1)
    oregon_cup = OregonCup.find(:first, :conditions => ['date = ?', date]) || OregonCup.new
    next_event = oregon_cup.next_event(today)
    body({:oregon_cup => oregon_cup, :next_event => next_event})
  end

  def standings(today = Date.today)
    @subject    = 'Oregon Cup Standings'
    @recipients = 'obra@list.obra.org'
    @from       = 'Scott Willson <scott@butlerpress.com>'
    date = Date.new(today.year, 1, 1)
    oregon_cup = OregonCup.find(:first, :conditions => ['date = ?', date]) || OregonCup.new
    body({:oregon_cup => oregon_cup, :today => today})
  end
end
