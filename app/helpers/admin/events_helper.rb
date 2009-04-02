module Admin::EventsHelper
  LONG_DAYS_OF_WEEK = %w{ Sunday Monday Tuesday Wednesday Thursday Friday Saturday } unless defined?(LONG_DAYS_OF_WEEK)
  
  def upcoming_events_table(upcoming_events, caption = nil, footer = nil)
    caption ||= link_to("Schedule", :only_path  => false, :host => RAILS_HOST, :controller => 'schedule')
    footer ||= link_to('More &hellip;', :only_path => false, :host => RAILS_HOST, :controller => 'schedule')
    render_page 'events/upcoming', :locals => { :upcoming_events => upcoming_events, :caption => caption, :footer => footer }
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
  
  def form_method_for(event)
    if event.new_record?
      :post
    else
      :put
    end
  end
end
