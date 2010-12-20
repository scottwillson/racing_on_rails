RacingOnRails::Application.routes.draw do
  namespace :admin do
    resources :articles
    resources :article_categories
    resources :categories do


      resources :children
    end
    resources :events do


      resources :races do
        collection do
          post :propagate
        end


      end
    end
    resources :first_aid_providers
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
        get :cards
        get :duplicates
        get :no_cards
        get :preview_import
      end
      member do
        get :card
        post :toggle_member
      end

    end
    resources :races do

      member do
        post :create_result
        delete :destroy_result
      end

    end
    resources :results
    resources :series
    resources :single_day_events
    resources :teams do

      member do
        post :toggle_member
      end

    end
    resources :people
    resources :velodromes
    resources :weekly_series
  end

  resources :articles
  resources :article_categories
  resources :categories
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
  match '/admin/cat4_womens_race_series/results' => 'admin/cat4_womens_race_series#create_result'
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
  match '/ironman/:year' => 'ironman#index', :as => :ironman
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
  match '/posts/:mailing_list_name/post' => 'posts#post'
  match '/posts/:mailing_list_name/confirm' => 'posts#confirm'
  match '/posts/:mailing_list_name/confirm_private_reply' => 'posts#confirm_private_reply'
  match '/posts/:mailing_list_name/:year/:month' => 'posts#list'
  match '/posts/:mailing_list_name' => 'posts#index'
  resources :posts

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
  end

  match '/people/:person_id/results' => 'results#person', :constraints => { :person_id => /\d+/ }
  match '/people/:person_id/:year' => 'results#person', :constraints => { :person_id => /\d+/, :year => /\d\d\d\d/ }
  match '/people/:person_id' => 'results#person', :constraints => { :person_id => /\d+/ }
  match '/people/list' => 'people#list'
  match '/people/new_login' => 'people#new_login'

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
  resources :teams
  match '/' => 'home#index'
  match '/track' => 'track#index', :as => :track
  match '/track/schedule' => 'track#schedule', :as => :track_schedule
  resource :person_session
  match '/unauthorized' => 'person_sessions#unauthorized', :as => :unauthorized
  match '/logout' => 'person_sessions#destroy', :as => :logout
  match '/login' => 'person_sessions#new', :as => :login
  match '/account/logout' => 'person_sessions#destroy'
  match '/account/login' => 'person_sessions#new'
  match '/account' => 'people#account', :as => :account
  match '/:controller' => '#index'
  match '/:controller/:id' => '#show', :constraints => { :id => /\d+/ }
  match '/:controller(/:action(/:id))'
  match '*path' => 'pages#show'
end
