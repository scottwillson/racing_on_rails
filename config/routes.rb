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

  map.connect "/admin/categories/:id", :controller => "admin/categories", :action => "index", :requirements => {:id => /\d+/}

  map.connect "/admin/promoters", :controller => 'admin/promoters', :action => "index"
  map.connect "/admin/promoters/:id", :controller => 'admin/promoters', :action => "show", :requirements => {:id => /\d+/}

  map.connect "/admin/racers", :controller => 'admin/racers', :action => "index"
  map.connect "/admin/racers/:id", :controller => 'admin/racers', :action => "show", :requirements => {:id => /\d+/}

  map.connect "/admin/results/:id/scores", :controller => "admin/results", :action => "scores"

  map.connect "/admin/schedule/:year/:action", :controller => "admin/schedule", :requirements => {:year => /\d+/}
  map.connect "/admin/schedule/:year", :controller => "admin/schedule", :action => "index", :requirements => {:year => /\d+/}
  map.connect "/admin", :controller => "admin/schedule", :action => "index"

  map.connect "/bar/categories", :controller => "bar", :action => 'categories'
  map.connect "/bar/:year/categories", :controller => "bar", :action => 'categories', :requirements => {:year => /\d+/}
  map.connect "/bar/:year/:discipline", :controller => "bar", :action => "show", :requirements => {:year => /\d+/}
  map.connect "/bar/:year", :controller => "bar", :action => "show", :requirements => {:year => /\d+/}
  map.connect "/bar", :controller => "bar", :action => "show"

  map.connect "/rider_rankings/:year/:discipline", :controller => "competitions", :action => "show", :type => 'rider_rankings', :requirements => {:year => /\d+/}
  map.connect "/rider_rankings/:year", :controller => "competitions", :action => "show", :type => 'rider_rankings', :requirements => {:year => /\d+/}
  map.connect "/rider_rankings", :controller => "competitions", :action => "show", :type => 'rider_rankings'

  map.connect "/ironman/:year", :controller => "ironman"

  map.connect "/oregon_cup/rules", :controller => "oregon_cup", :action => "rules"
  map.connect "/oregon_cup/races", :controller => "oregon_cup", :action => "races"
  map.connect "/oregon_cup/:year", :controller => "oregon_cup", :action => "index"
  map.connect "/oregon_cup", :controller => "oregon_cup", :action => "index"

  map.connect "/posts/:mailing_list_name/new/:reply_to", :controller => "posts", :action => "new"
  map.connect "/posts/:mailing_list_name/new",           :controller => "posts", :action => "new"
  map.connect "/posts/new/:mailing_list_name",           :controller => "posts", :action => "new"
  map.connect "/posts/:mailing_list_name/show/:id",      :controller => "posts", :action => "show"
  map.connect "/posts/show/:mailing_list_name/:id",      :controller => "posts", :action => "show"
  map.connect "/posts/:mailing_list_name/post",          :controller => "posts", :action => "post"
  map.connect "/posts/:mailing_list_name/confirm",       :controller => "posts", :action => "confirm"
  map.connect "/posts/:mailing_list_name/confirm_private_reply", :controller => "posts", :action => "confirm_private_reply"
  map.connect "/posts/:mailing_list_name/:year/:month",  :controller => "posts", :action => "list"
  map.connect "/posts/:mailing_list_name",               :controller => "posts"

  map.connect "/results/competition/:competition_id/racer/:racer_id", :controller => "results", :action => "competition"
  map.connect "/results/competition/:competition_id/team/:team_id", :controller => "results", :action => "competition"
  map.connect "/results/event/:id", :controller => "results", :action => "event"
  map.connect "/results/racer/:id", :controller => "results", :action => "racer"
  map.connect "/results/show/:id", :controller => "results", :action => "show"
  map.connect "/results/team/:id", :controller => "results", :action => "team"
  map.connect "/results/:year/:discipline", :controller => "results"
  map.connect "/results/:year/:discipline/:id", :controller => "results", :action => "event", :requirements => {:year => /\d\d\d\d/}
  map.connect "/results/:year", :controller => "results", :action => "index", :requirements => {:year => /\d\d\d\d/}
  map.connect "/results/:discipline", :controller => "results"

  map.connect "/schedule/:year/:action", :controller => "schedule", :requirements => {:year => /\d\d\d\d/}
  map.connect "/schedule/:year", :controller => "schedule", :action => "index", :requirements => {:year => /\d\d\d\d/}
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
