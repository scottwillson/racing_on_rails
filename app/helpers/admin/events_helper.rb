module Admin::EventsHelper
  LONG_DAYS_OF_WEEK = %w{ Sunday Monday Tuesday Wednesday Thursday Friday Saturday } unless defined?(LONG_DAYS_OF_WEEK)

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
      link_to(event.full_name, event.flyer).html_safe
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
    html.html_safe
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
