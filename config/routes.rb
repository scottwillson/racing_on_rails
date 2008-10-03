ActionController::Routing::Routes.draw do |map|
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

  map.namespace(:admin) do |admin|
    admin.resources :racers, :collection => { :cards => :get, :duplicates => :get, :mailing_labels => :get, :no_mailing_labels => :get, :no_cards => :get }, 
                             :member => { :card => :get }
    admin.resources :teams
    admin.resources :velodromes
  end

  map.resources :teams
  
  map.connect ":controller/:id/aliases/:alias_id/destroy", :action => 'destroy_alias', :requirements => {:id => /\d+/}

  map.connect "/admin/results/:id/scores", :controller => "admin/results", :action => "scores"

  map.connect "/admin/schedule/:year/:action", :controller => "admin/schedule", :requirements => {:year => /\d+/}
  map.connect "/admin/schedule/:year", :controller => "admin/schedule", :action => "index", :requirements => {:year => /\d+/}
  map.connect "/admin", :controller => "admin/schedule", :action => "index"

  map.connect "/bar/categories", :controller => "bar", :action => 'categories'
  map.connect "/bar/:year/categories", :controller => "bar", :action => 'categories', :requirements => {:year => /\d+/}
  map.connect "/bar", :controller => "bar", :action => "index"
  map.connect "/bar/:year/:discipline/:category", 
              :controller => "bar", :action => "show", 
              :requirements => {:year => /\d+/}, 
              :defaults => {:discipline => 'overall', :category => 'senior_men'}

  map.connect "/cat4_womens_race_series/:year/:discipline", :controller => "competitions", :action => "show", :type => 'cat4_womens_race_series', :requirements => {:year => /\d+/}
  map.connect "/cat4_womens_race_series/:year", :controller => "competitions", :action => "show", :type => 'cat4_womens_race_series', :requirements => {:year => /\d+/}
  map.connect "/cat4_womens_race_series", :controller => "competitions", :action => "show", :type => 'cat4_womens_race_series'

  map.connect "/admin/cat4_womens_race_series/results/new", :controller => "admin/cat4_womens_race_series", :action => "new_result"
  map.connect "/admin/cat4_womens_race_series/results", :controller => "admin/cat4_womens_race_series", :action => "create_result"

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

  map.connect "/schedule/list/:discipline", :controller => "schedule", :action => "list"
  map.connect "/schedule/:year/list/:discipline", :controller => "schedule", :action => "list", :requirements => {:year => /\d\d\d\d/}
  map.connect "/schedule/:year/list", :controller => "schedule", :action => "list", :requirements => {:year => /\d\d\d\d/}
  map.connect "/schedule/:year/:discipline", :controller => "schedule", :action => "index", :requirements => {:year => /\d\d\d\d/}
  map.connect "/schedule/:year", :controller => "schedule", :action => "index", :requirements => {:year => /\d\d\d\d/}
  map.connect "/schedule/list", :controller => "schedule", :action => "list"
  map.connect "/schedule/:discipline", :controller => "schedule", :action => "index"
  
  map.resources :subscriptions, :collection => { :subscribed => :get }

  map.track "/track", :controller => "track"
  map.track_schedule "/track/schedule", :controller => "track", :action => "schedule"

  map.connect '', :controller => "home"

  map.connect "/:controller", :action => "index"
  map.connect "/:controller/:id", :action => "show", :requirements => {:id => /\d+/}

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'
end
