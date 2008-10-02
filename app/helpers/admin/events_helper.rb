module Admin::EventsHelper
  BAR_POINTS_AND_LABELS = [['None', 0], ['Normal', 1], ['Double', 2], ['Triple', 3]] unless defined?(BAR_POINTS_AND_LABELS)
  LONG_DAYS_OF_WEEK = %w{ Sunday Monday Tuesday Wednesday Thursday Friday Saturday } unless defined?(LONG_DAYS_OF_WEEK)
  
  def bar_points_and_labels
    BAR_POINTS_AND_LABELS
  end
  
  def number_issuers
    select('event', 'number_issuer_id', NumberIssuer.find(:all, :order => 'name').collect {|i| [i.name, i.id]})
  end
  
  def upcoming_events_table(upcoming_events, caption = nil, footer = nil)
    caption ||= link_to("Schedule", :only_path  => false, :host => RAILS_HOST, :controller => 'schedule')
    footer ||= link_to('More &hellip;', :only_path => false, :host => RAILS_HOST, :controller => 'schedule')
    render :partial => 'events/upcoming', :locals => { :upcoming_events => upcoming_events, :caption => caption, :footer => footer }
  end
  
  def discipline_upcoming_events(discipline, upcoming_events)
    if upcoming_events.disciplines.size > 1
      caption = discipline.name.upcase
    else
      caption = nil
    end
    render :partial => 'events/discipline_upcoming', :locals => { :discipline => discipline, :dates => upcoming_events.dates, :caption => caption }
  end
  
  def long_day_of_week(index)
    LONG_DAYS_OF_WEEK[index]
  end
end
