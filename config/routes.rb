ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  map.connect "/admin/events/update_bar_points/:id", :controller => "admin/events", :action => "update_bar_points"
  map.connect "/admin/events/upcoming", :controller => "admin/events", :action => "upcoming"
  map.connect "/admin/events/update/:id/:standings_id", :controller => "admin/events", :action => "update", :requirements => {:id => /\d+/, :standings_id => /\d+/}
  map.connect "/admin/events/:id/:standings_id/:race_id", :controller => "admin/events", :action => "show"
  map.connect "/admin/events/:id/:standings_id", :controller => "admin/events", :action => "show", :requirements => {:id => /\d+/, :standings_id => /\d+/}
  map.connect "/admin/events/:id", :controller => "admin/events", :action => "show", :requirements => {:id => /\d+/}
  map.connect "/admin/events/new/:year", :controller => "admin/events", :action => 'new', :requirements => {:year => /\d+/}
  map.connect "/admin/events/:action/:id", :controller => "admin/events"
  map.connect "/admin/events/:action", :controller => "admin/events"

  map.connect "/admin/racers", :controller => 'admin/racers', :action => "index"
  map.connect "/admin/racers/:id", :controller => 'admin/racers', :action => "show", :requirements => {:id => /\d+/}

  map.connect "/admin/schedule/:year/:action", :controller => "admin/schedule"
  map.connect "/admin/schedule/:year", :controller => "admin/schedule", :action => "index"
  map.connect "/admin", :controller => "admin/schedule", :action => "index"

  map.connect "/results/racer/:id", :controller => "results", :action => "racer"
  map.connect "/results/show/:id", :controller => "results", :action => "show"
  map.connect "/results/:year/:discipline/:id", :controller => "results", :action => "event"
  map.connect "/results/:year", :controller => "results", :action => "index"

  map.connect "/schedule/:year/:action", :controller => "schedule", :requirements => {:year => /\d+/}
  map.connect "/schedule/:year", :controller => "schedule", :action => "index", :requirements => {:year => /\d+/}
  map.connect "/schedule/:action", :controller => "schedule"

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  map.connect '', :controller => "home"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
