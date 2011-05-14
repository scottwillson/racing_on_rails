RacingOnRails::Application.routes.draw do
  namespace :admin do
    resources :articles
    resources :article_categories
    resources :categories do
      collection do
        post :add_child
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
        post :propagate
        get  :set_parent
        post :upload_schedule
      end
      member do
        get     :create_from_children
        delete  :destroy_races
        post    :set_event_chief_referee
        post    :set_event_first_aid_provider
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
    resources :pages do
      post :set_page_title, :on => :member
    end
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
        get  :card
        post :number_year_changed
        post :toggle_member
      end
      resources :results
    end
    resources :races do
      member do
        post :create_result
        delete :destroy_result
        post :set_race_category_name
      end
    end
    resources :results do
      collection do
        post :find_person
        post :results
      end
      member do
        post :move_result
        post :set_result_age
        post :set_result_bar
        post :set_result_city
        post :set_result_category_name
        post :set_result_date_of_birth
        post :set_result_distance
        post :set_result_laps
        post :set_result_license
        post :set_result_name
        post :set_result_notes
        post :set_result_number
        post :set_result_place
        post :set_result_points
        post :set_result_points_bonus
        post :set_result_points_bonus_penalty
        post :set_result_points_from_place
        post :set_result_points_penalty
        post :set_result_points_total
        post :set_result_state
        post :set_result_team_name
        post :set_result_time_bonus_penalty_s
        post :set_result_time_gap_to_leader_s
        post :set_result_time_gap_to_winner_s
        post :set_result_time_s
        post :set_result_time_total_s
      end
    end
    
    resources :series
    resources :single_day_events
    resources :teams do
      member do
        post :cancel_in_place_edit
        post :destroy_name
        get  :merge
        post :set_team_name
        post :toggle_member
      end
    end
    resources :velodromes do
      member do
        post :set_velodrome_name
        post :set_velodrome_website
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
  match '/bar/categories' => 'bar#categories'
  match '/bar/:year/categories' => 'bar#categories', :constraints => { :year => /\d+/ }
  match '/bar' => 'bar#index'
  match '/bar/:year/:discipline/:category' => 'bar#show', :as => :bar, :defaults => { :discipline => 'overall', :category => 'senior_men' }, :constraints => { :year => /\d+/ }
  match '/cat4_womens_race_series/:year' => 'competitions#show', :as => :cat4_womens_race_series, :type => 'cat4_womens_race_series', :constraints => { :year => /\d+/ }
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

  match '/rider_rankings/:year' => 'competitions#show', :as => :rider_rankings, :type => 'rider_rankings', :constraints => { :year => /\d+/ }
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
  match '/people/:person_id/:year' => 'results#person', :constraints => { :person_id => /\d+/, :year => /\d\d\d\d/ }
  match '/people/:person_id' => 'results#person', :constraints => { :person_id => /\d+/ }, :via => :get
  match '/people/list' => 'people#list'
  match '/people/new_login' => 'people#new_login'
  match "/people/:id/account" => redirect("/people/%{id}/edit"), :constraints => { :person_id => /\d+/ }
  resources :people do
    resources :editors do
      member do
        get :create
        get :destroy
      end
    end

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
  match '/teams/:team_id/:year' => 'results#team', :constraints => { :person_id => /\d+/, :year => /\d\d\d\d/ }
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
