module Admin::EventsHelper
  LONG_DAYS_OF_WEEK = %w{ Sunday Monday Tuesday Wednesday Thursday Friday Saturday } unless defined?(LONG_DAYS_OF_WEEK)
  
  # Build a caption and footer links and render events/upcoming partial
  def upcoming_events_table(upcoming_events, caption = nil, footer = nil)
    caption ||= link_to("Schedule", :only_path  => false, :host => RAILS_HOST, :controller => 'schedule')
    footer ||= link_to('More &hellip;', :only_path => false, :host => RAILS_HOST, :controller => 'schedule')
    render_page 'events/upcoming', :locals => { :upcoming_events => upcoming_events, :caption => caption, :footer => footer }
  end
  
  # Road upcoming events, Track upcoming events, etc …
  def discipline_upcoming_events(discipline, upcoming_events)
    if upcoming_events.disciplines.size > 1
      caption = discipline.name.upcase
    else
      caption = "&nbsp;"
    end
    render :partial => 'events/discipline_upcoming', :locals => { :discipline => discipline, :dates => upcoming_events.dates, :caption => caption }
  end

  # Sunday, Monday, …
  def long_day_of_week(index)
    LONG_DAYS_OF_WEEK[index]
  end
  
  # Show link even if not approved because this is for admins
  def link_to_flyer(event)
    return unless event
    
    if event.flyer.blank?
      event.full_name
    else
      link_to event.full_name, event.flyer
    end
  end
  
  # Build links like Cascade Classic: Mt. Bachelor Stage
  def link_to_parents(event)
    html = ""
    event.ancestors.reverse.each do |e|
      if e.parent
        html << link_to(truncate(e.name, :length => 40), edit_admin_event_path(e), :class => "obvious")
        html << ": "
      else
        html << link_to(truncate(e.name, :length => 40), edit_admin_event_path(e), :class => "obvious")
        html << " (#{e.friendly_class_name}): "
      end
    end
    html
  end
  
  # Choose POST or PUT. Not sure why we need this.
  def form_method_for(event)
    if event.new_record?
      :post
    else
      :put
    end
  end
end
