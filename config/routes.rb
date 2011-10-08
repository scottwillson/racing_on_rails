RacingOnRails::Application.routes.draw do
  namespace :admin do
    resources :articles
    resources :article_categories
    resources :categories do
      collection do
        post :add_child
        post :recompute_bar 
        post :recompute_team_bar 
      end
    end
    
    resource :cat4_womens_race_series do
      collection do
        post :create_result
      end
    end
    
    resources :events do
      collection do
        get  :add_children
        get  :set_parent
        post :upload_schedule
      end
      member do
        get     :create_from_children
        delete  :destroy_races
        put     :update_attribute
        post    :upload
      end
      resources :races do
        collection do
          post :propagate
        end
      end
    end
    resources :first_aid_providers
    resources :mailing_list do
      resources :posts do
        collection do
          post :receive
        end
      end
    end
    resources :multi_day_events
    resources :pages
    namespace :pages do
      resources :versions do
        member do
          get :revert
        end
      end
    end
    resources :people do
      collection do
        get  :cards
        get  :duplicates
        post :import
        get  :no_cards
        post :preview_import
        post :resolve_duplicates
      end
      member do
        get    :card
        post   :toggle_member
      end
      resources :race_numbers
      resources :results do
        post :move
      end
      resources :scores
    end
    match "/people/:id/merge/:other_person_id" => "people#merge", :constraints => { :id => /\d+/, :other_person_id => /\d+/ }, :via => :post, :as => :merge_person

    resources :races do
      member do
        post :create_result
        delete :destroy_result
        put :update_attribute
      end
    end
    
    resources :results do
      collection do
        post :find_person
        post :results
      end
      member do
        put  :update_attribute
      end
    end
    
    resources :series
    resources :single_day_events

    resources :teams do
      member do
        post :cancel_in_place_edit
        post :destroy_name
        post :toggle_member
        put  :update_attribute
      end
    end
    match "/teams/:id/merge/:other_team_id" => "teams#merge", :constraints => { :id => /\d+/, :other_team_id => /\d+/ }, :via => :post, :as => :merge_team

    resources :velodromes do
      member do
        put  :update_attribute
      end
    end
    resources :weekly_series
  end

  resources :articles
  resources :article_categories
  resources :categories do
    resources :races
  end
  match ':controller/:id/aliases/:alias_id/destroy' => '#destroy_alias', :constraints => { :id => /\d+/ }
  match '/admin/results/:id/scores' => 'admin/results#scores'
  match '/admin/racers' => 'admin/racers#index'
  match '/admin/persons/:action/:id' => 'admin/people#index', :as => :admin_persons
  match '/admin' => 'admin/home#index', :as => :admin_home
  match '/bar' => 'bar#index', :as => "bar_root"
  match "/bar/:year/:discipline/:category" => "bar#show", 
        :as => "bar",
        :defaults => { :discipline => "overall", :category => "senior_men" }
  match "/bar/:year/:discipline" => "bar#show", 
        :category => "senior_men",
        :defaults => { :discipline => "overall" }
        
  match "/bar/:year" => "bar#show", 
        :category => "senior_men",
        :discipline => "overall",
        :defaults => { :discipline => "overall" }

  match '/cat4_womens_race_series/:year' => 'competitions#show', :as => :cat4_womens_race_series, :type => 'cat4_womens_race_series', :constraints => { :year => /\d{4}/ }
  match '/cat4_womens_race_series' => 'competitions#show', :type => 'cat4_womens_race_series'
  match '/admin/cat4_womens_race_series/results/new' => 'admin/cat4_womens_race_series#new_result', :as => :new_admin_cat4_womens_race_series_result
  match '/events/:event_id/results' => 'results#event'
  match '/events/:event_id/people/:person_id/results' => 'results#person_event'
  match '/events/:event_id/teams/:team_id/results' => 'results#team_event'
  match '/events/:event_id/teams/:team_id/results/:race_id' => 'results#team_event'
  match '/events/:event_id' => 'results#event'

  resources :events do
    resources :results
    resources :people do
      resources :results
    end
    resources :teams do
      resources :results
    end
  end

  match '/rider_rankings/:year' => 'competitions#show', :as => :rider_rankings, :type => 'rider_rankings', :constraints => { :year => /\d{4}/ }
  match '/rider_rankings' => 'competitions#show', :as => :rider_rankings_root, :type => 'rider_rankings'
  match '/ironman(/:year)' => 'ironman#index', :as => :ironman
  match '/mailing_lists' => 'mailing_lists#index', :as => :mailing_lists

  resources :update_requests do
    member do
      get :confirm
    end
  end

  match '/oregon_cup/rules' => 'oregon_cup#rules'
  match '/oregon_cup/races' => 'oregon_cup#races'
  match '/oregon_cup/:year' => 'oregon_cup#index', :as => :oregon_cup
  match '/oregon_cup' => 'oregon_cup#index', :as => :oregon_cup_root
  resources :password_resets
  match '/posts/:mailing_list_name/new/:reply_to_id' => 'posts#new'
  match '/posts/:mailing_list_name/new' => 'posts#new'
  match '/posts/new/:mailing_list_name' => 'posts#new'
  match '/posts/:mailing_list_name/show/:id' => 'posts#show'
  match '/posts/show/:mailing_list_name/:id' => 'posts#show'
  match '/posts/show' => 'posts#show'
  match '/posts/:mailing_list_name/post' => 'posts#post'
  match '/posts/:mailing_list_name/confirm' => 'posts#confirm'
  match '/posts/:mailing_list_name/confirm_private_reply' => 'posts#confirm_private_reply'
  match '/posts/:mailing_list_name/:year/:month' => 'posts#list'
  match '/posts/:mailing_list_name' => 'posts#index'
  resources :posts do
    get :list, :on => :collection
  end

  match '/people/:person_id/results' => 'results#person', :constraints => { :person_id => /\d+/ }
  match '/people/:person_id/:year' => 'results#person', :constraints => { :person_id => /\d+/, :year => /\d\d\d\d/ }, :as => :person_results_year
  match '/people/:person_id' => 'results#person', :constraints => { :person_id => /\d+/ }, :via => :get
  match '/people/list' => 'people#list'
  match '/people/new_login' => 'people#new_login'
  match '/people/:id/new_login' => 'people#new_login'
  match "/people/:id/account" => redirect("/people/%{id}/edit"), :constraints => { :person_id => /\d+/ }, :as => :account_person

  match "/people/:id/editors/:editor_id/create" => "editors#create", :constraints => { :id => /\d+/, :editor_id => /\d+/ }, :via => :get, :as => :create_person_editor
  match "/people/:id/editors/:editor_id/destroy" => "editors#destroy", :constraints => { :id => /\d+/, :editor_id => /\d+/ }, :via => :get, :as => :destroy_person_editor
  match "/people/:id/editor_requests/:editor_id/create" => "editor_requests#create", :constraints => { :id => /\d+/, :editor_id => /\d+/ }, :via => :get, :as => :create_person_editor_request
  match "/people/:id/editor_requests/:editor_id/destroy" => "editor_requests#destroy", :constraints => { :id => /\d+/, :editor_id => /\d+/ }, :via => :get, :as => :destroy_person_editor_request

  resources :people do
    post :create_login, :on => :collection
    resources :editors
    resources :editor_requests
    resources :events
    resource :membership
    resources :orders
    resources :results
    resources :versions
    collection do
      get :account
    end
  end

  resources :racing_associations
  match '/results/:year/:discipline' => 'results#index', :constraints => { :year => /(19|20)\d\d/ }
  match '/results/:year' => 'results#index', :constraints => { :year => /(19|20)\d\d/ }
  match '/results/:discipline' => 'results#index'
  resources :results
  match '/schedule/:year/calendar' => 'schedule#calendar', :constraints => { :year => /\d\d\d\d/ }
  match '/schedule/calendar' => 'schedule#calendar'
  match '/schedule/list/:discipline' => 'schedule#list'
  match '/schedule/:year/list/:discipline' => 'schedule#list', :constraints => { :year => /\d\d\d\d/ }
  match '/schedule/:year/list' => 'schedule#list', :constraints => { :year => /\d\d\d\d/ }
  match '/schedule/:year/:discipline' => 'schedule#index', :constraints => { :year => /\d\d\d\d/ }
  match '/schedule/:year' => 'schedule#index', :constraints => { :year => /\d\d\d\d/ }
  match '/schedule/list' => 'schedule#list'
  match '/schedule/:discipline' => 'schedule#index'
  match '/schedule' => 'schedule#index', :as => :schedule
  resources :single_day_events
  match '/teams/:team_id/results' => 'results#team'
  match '/teams/:team_id/:year' => 'results#team', :constraints => { :person_id => /\d+/, :year => /\d\d\d\d/ }, :as => :team_results_year
  match '/teams/:team_id' => 'results#team'
  resources :teams do
    resources :results
  end
  match '/' => 'home#index', :as => :root
  match '/track' => 'track#index', :as => :track
  match '/track/schedule' => 'track#schedule', :as => :track_schedule
  resource :person_session
  match '/unauthorized' => 'person_sessions#unauthorized', :as => :unauthorized
  match '/logout' => 'person_sessions#destroy', :as => :logout
  match '/login' => 'person_sessions#new', :as => :login
  match '/account/logout' => 'person_sessions#destroy'
  match '/account/login' => 'person_sessions#new'
  match '/account' => 'people#account', :as => :account

  match '/wsba_barr' => 'competitions#show', :as => :wsba_barr_root, :type => 'wsba_barr'

  match '*path', :to => 'pages#show'
  
  if Rails.env.test?
    resources :fake do
      collection do
        get :missing_partial
        get :news
        get :partial_using_action
        get :partial_using_partials_action
        get :recent_results
        get :upcoming_events
      end
    end
  end
end
