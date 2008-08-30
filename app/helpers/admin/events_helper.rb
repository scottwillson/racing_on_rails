module Admin::EventsHelper
  BAR_POINTS_AND_LABELS = [['None', 0], ['Normal', 1], ['Double', 2], ['Triple', 3]] unless defined?(BAR_POINTS_AND_LABELS)
  
  def bar_points_and_labels
    BAR_POINTS_AND_LABELS
  end
  
  def number_issuers
    select('event', 'number_issuer_id', NumberIssuer.find(:all, :order => 'name').collect {|i| [i.name, i.id]})
  end
  
  def upcoming_events(caption = nil, footer = nil)
    caption ||= link_to("Schedule", :only_path  => false, :host => RAILS_HOST, :controller => 'schedule')
    footer ||= link_to('More &hellip;', :only_path => false, :host => RAILS_HOST, :controller => 'schedule')
    render :partial => 'events/upcoming', :locals => { :caption => caption, :footer => footer }
  end
end
