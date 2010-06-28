ActionController::Routing::Routes.draw do |map|
  map.namespace(:admin) do |admin|
    admin.resources :articles
    admin.resources :article_categories
    admin.resources :categories do |category|
      category.resources :children, :controller => :categories
    end
    admin.resources :events, :has_one => :person, :has_many => :races,
        :collection => { :upload_schedule => :post }, 
        :member => { :upload => :post, 
                     :set_parent => :get, 
                     :add_children => :get, 
                     :create_from_children => :get, 
                     :destroy_races => :delete }
    admin.resources :first_aid_providers
    admin.resources :multi_day_events, :as => :events, :has_one => :person
    
    admin.resources :pages
    admin.namespace(:pages) do |pages|
      pages.resources :versions, :member => { :revert => :get }
    end

    admin.resources :people, :collection => { :cards => :get, 
                                              :duplicates => :get, 
                                              :no_cards => :get, 
                                              :preview_import => :get },
                             :member => { :card => :get, :toggle_member => :post },
                             :has_many => :results
    admin.resources :races, :has_many => :results, :member => { :create_result => :post, :destroy_result => :delete }
    admin.resources :results
    admin.resources :series, :as => :events, :has_one => :person
    admin.resources :single_day_events, :as => :events, :has_one => :person
    admin.resources(:tables) if RAILS_ENV == "test"
    admin.resources :teams, :member => { :toggle_member => :post }
    admin.resources :people, :has_many => :events, :has_many => :single_day_events
    admin.resources :velodromes
    admin.resources :weekly_series, :as => :events, :has_one => :person
  end

  map.resources :articles
  map.resources :article_categories
  map.resources :categories, :has_many => :races

  map.connect ":controller/:id/aliases/:alias_id/destroy", :action => 'destroy_alias', :requirements => {:id => /\d+/}

  map.connect "/admin/results/:id/scores", :controller => "admin/results", :action => "scores"
  
  # Redirect for legacy URLs
  map.connect "/admin/racers", :controller => "admin/racers"
  
  # Inplace editor workaround
  map.admin_persons "/admin/persons/:action/:id", :controller => "admin/people"

  map.admin_home "/admin", :controller => "admin/home", :action => "index"

  map.connect "/bar/categories", :controller => "bar", :action => 'categories'
  map.connect "/bar/:year/categories", :controller => "bar", :action => 'categories', :requirements => {:year => /\d+/}
  map.connect "/bar", :controller => "bar", :action => "index"
  map.bar "/bar/:year/:discipline/:category",
              :controller => "bar", :action => "show",
              :requirements => {:year => /\d+/},
              :defaults => {:discipline => 'overall', :category => 'senior_men'}

  map.cat4_womens_race_series "/cat4_womens_race_series/:year", :controller => "competitions", :action => "show", :type => 'cat4_womens_race_series', :requirements => {:year => /\d+/}
  map.connect "/cat4_womens_race_series", :controller => "competitions", :action => "show", :type => 'cat4_womens_race_series'

  map.new_admin_cat4_womens_race_series_result "/admin/cat4_womens_race_series/results/new", :controller => "admin/cat4_womens_race_series", :action => "new_result"
  map.connect "/admin/cat4_womens_race_series/results", :controller => "admin/cat4_womens_race_series", :action => "create_result"

  map.connect "/events/:event_id/results", :controller => "results", :action => "event"
  map.connect "/events/:event_id/people/:person_id/results", :controller => "results", :action => "person_event"
  map.connect "/events/:event_id/teams/:team_id/results", :controller => "results", :action => "team_event"
  map.connect "/events/:event_id", :controller => "results", :action => "event"
  map.resources :events do |events|
    events.resources :results

    events.resources :people do |people|
      people.resources :results
    end
    
    events.resources :teams do |team|
      team.resources :results
    end
  end
  
  map.rider_rankings "/rider_rankings/:year", :controller => "competitions", :action => "show", :type => 'rider_rankings', :requirements => {:year => /\d+/}
  map.rider_rankings_root "/rider_rankings", :controller => "competitions", :action => "show", :type => 'rider_rankings'

  map.ironman "/ironman/:year", :controller => "ironman"

  map.mailing_lists "/mailing_lists", :controller => "mailing_lists", :action => "index"
  
  map.resources :update_requests, :member => { :confirm => :get }
  map.connect "/oregon_cup/rules", :controller => "oregon_cup", :action => "rules"
  map.connect "/oregon_cup/races", :controller => "oregon_cup", :action => "races"
  map.oregon_cup "/oregon_cup/:year", :controller => "oregon_cup", :action => "index"
  map.oregon_cup_root "/oregon_cup", :controller => "oregon_cup", :action => "index"
  
  map.resources :password_resets

  map.connect "/posts/:mailing_list_name/new/:reply_to_id", :controller => "posts", :action => "new"
  map.connect "/posts/:mailing_list_name/new",              :controller => "posts", :action => "new"
  map.connect "/posts/new/:mailing_list_name",              :controller => "posts", :action => "new"
  map.connect "/posts/:mailing_list_name/show/:id",         :controller => "posts", :action => "show"
  map.connect "/posts/show/:mailing_list_name/:id",         :controller => "posts", :action => "show"
  map.connect "/posts/:mailing_list_name/post",             :controller => "posts", :action => "post"
  map.connect "/posts/:mailing_list_name/confirm",          :controller => "posts", :action => "confirm"
  map.connect "/posts/:mailing_list_name/confirm_private_reply", :controller => "posts", :action => "confirm_private_reply"
  map.connect "/posts/:mailing_list_name/:year/:month",     :controller => "posts", :action => "list"
  map.connect "/posts/:mailing_list_name",                  :controller => "posts"
  map.resources :posts

  map.connect "/people/:person_id/results", :controller => "results", :action => "person", :requirements => { :person_id => /\d+/ }
  map.connect "/people/:person_id/:year", :controller => "results", :action => "person", 
              :requirements => { :person_id => /\d+/, :year => /\d\d\d\d/ }, 
              :conditions => { :method => :get }
  map.connect "/people/:person_id", :controller => "results", :action => "person", 
              :requirements => { :person_id => /\d+/ }, 
              :conditions => { :method => :get }
  map.resources :people, 
                :member => { :card => :get, :account => :get, :membership => :get },
                :collection => { :membership_information => :get, :account => :get, :new_login => :get, :create_login => :post } do |person|
                  person.resources :editors, :member => { :create => :get, :destroy => :get }
                  person.resources :editor_requests
                  person.resources :events
                  person.resource :membership
                  person.resources :orders
                  person.resources :results
                  person.resources :versions
                end
  
  # Deprecated URLs
  map.connect "/results/:year/:discipline/:event_id", 
              :controller => "results", 
              :action => "deprecated_event", 
              :requirements => { :year => /(19|20)\d\d/, :discipline => /\w+.*/, :event_id => /\d+/ }
  map.connect "/results/show/:id", :controller => "results", :action => "show"
  map.connect "/results/competition/:event_id/racer/:person_id", :controller => "results", :action => "competition"
  map.connect "/results/competition/:event_id/team/:team_id", :controller => "results", :action => "competition"
  map.connect "/results/event/:event_id", :controller => "results", :action => "deprecated_event", :requirements => { :event_id => /\d+/ }
  map.connect "/results/racer/:person_id", :controller => "results", :action => "racer", :requirements => { :person_id => /\d+/ }
  map.connect "/results/team/:team_id", :controller => "results", :action => "deprecated_team", :requirements => { :team_id => /\d+/ }

  map.connect "/results/:year/:discipline", :controller => "results", :requirements => { :year => /(19|20)\d\d/ }
  map.connect "/results/:year", :controller => "results", :action => "index", :requirements => { :year => /(19|20)\d\d/ }
  map.connect "/results/:discipline", :controller => "results" 
  
  # Reserve /results/2008 for /results/:year
  map.resources :results, :except => "show"

  map.connect "/schedule/:year/calendar", :controller => "schedule", :action => "calendar", :requirements => {:year => /\d\d\d\d/}
  map.connect "/schedule/calendar", :controller => "schedule", :action => "calendar"
  map.connect "/schedule/list/:discipline", :controller => "schedule", :action => "list"
  map.connect "/schedule/:year/list/:discipline", :controller => "schedule", :action => "list", :requirements => {:year => /\d\d\d\d/}
  map.connect "/schedule/:year/list", :controller => "schedule", :action => "list", :requirements => {:year => /\d\d\d\d/}
  map.connect "/schedule/:year/:discipline", :controller => "schedule", :action => "index", :requirements => {:year => /\d\d\d\d/}
  map.connect "/schedule/:year", :controller => "schedule", :action => "index", :requirements => {:year => /\d\d\d\d/}
  map.connect "/schedule/list", :controller => "schedule", :action => "list"
  map.connect "/schedule/:discipline", :controller => "schedule", :action => "index"
  map.schedule "/schedule", :controller => "schedule"

  map.resources :single_day_events, :as => :events

  map.connect "/teams/:team_id/results", :controller => "results", :action => "team"
  map.connect "/teams/:team_id/:year", :controller => "results", :action => "team", :requirements => { :person_id => /\d+/, :year => /\d\d\d\d/ }
  map.connect "/teams/:team_id", :controller => "results", :action => "team"
  map.resources :teams, :has_many => :results

  map.root :controller => "home"
  map.track "/track", :controller => "track"
  map.track_schedule "/track/schedule", :controller => "track", :action => "schedule"
  

  map.resource :person_session
  map.unauthorized "/unauthorized", :controller => "person_sessions", :action => "unauthorized"
  map.logout "/logout", :controller => "person_sessions", :action => "destroy"
  map.login "/login", :controller => "person_sessions", :action => "new"
  map.connect "/account/logout", :controller => "person_sessions", :action => "destroy"
  map.connect "/account/login", :controller => "person_sessions", :action => "new"
  map.account "/account", :controller => "people", :action => "account"

  map.connect "/:controller", :action => "index"
  map.connect "/:controller/:id", :action => "show", :requirements => {:id => /\d+/}

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id'

  map.connect "*path", :controller => "pages", :action => "show"
end
