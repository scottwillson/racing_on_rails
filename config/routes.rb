Rails.application.routes.draw do
  scope "(:mobile)", mobile: /m/ do
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

      resources :events do
        collection do
          get  :add_children
          get  :set_parent
          post :upload_schedule
        end
        member do
          get     :create_from_children
          delete  :destroy_races
          patch   :update_attribute
          post    :upload
        end
        resources :races do
          collection do
            post :propagate
          end
        end
      end
      resources :first_aid_providers
      resources :mailing_lists do
        resources :posts do
          collection do
            post :receive
          end
        end
      end
      resources :multi_day_events
      resources :pages do
        member do
          patch :update_attribute
        end
      end
      namespace :pages do
        resources :versions do
          member do
            get :revert
          end
        end
      end
      resources :people do
        resources :aliases
        collection do
          get  :cards
          get  :duplicates
          post :import
          get  :no_cards
          post :number_year_changed
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
      post "/people/:id/merge/:other_person_id" => "people#merge", constraints: { id: /\d+/, other_person_id: /\d+/ }, as: :merge_person

      resources :races do
        member do
          patch :update_attribute
        end
        resources :results
      end

      resources :race_numbers

      resources :results do
        collection do
          post :find_person
          post :results
        end
        member do
          patch :update_attribute
        end
        resources :races
      end

      resources :series
      resources :single_day_events

      resources :teams do
        resources :aliases
        member do
          post  :cancel_in_place_edit
          post  :destroy_name
          post  :toggle_member
          patch :update_attribute
        end
      end
      post "/teams/:id/merge/:other_team_id" => "teams#merge", constraints: { id: /\d+/, other_team_id: /\d+/ }, as: :merge_team

      resources :velodromes do
        member do
          patch :update_attribute
        end
      end
      resources :weekly_series
    end

    resources :articles
    resources :article_categories
    resources :categories do
      resources :races
    end
    get ':controller/:id/aliases/:alias_id/destroy' => '#destroy_alias', constraints: { id: /\d+/ }
    get '/admin/results/:id/scores' => 'admin/results#scores'
    get '/admin/racers' => 'admin/racers#index'
    patch '/admin/persons/update_attribute/:id' => 'admin/people#update_attribute'
    get '/admin' => 'admin/home#index', as: :admin_home
    get '/bar' => 'competitions/bar#index', as: "bar_root"
    get "/bar/:year/:discipline/:category" => "competitions/bar#show", as: "bar_full"
    get "/bar(/:year(/:discipline(/:category)))" => "competitions/bar#show", as: "bar", defaults: { discipline: "overall", category: "senior_men" }
    get '/cat4_womens_race_series/:year' => 'competitions/competitions#show', as: :cat4_womens_race_series, type: 'cat4_womens_race_series', constraints: { year: /\d{4}/ }
    get '/cat4_womens_race_series' => 'competitions/competitions#show', type: 'cat4_womens_race_series'
    get '/events/:event_id/results' => 'results#event'
    get '/events/:event_id/people/:person_id/results' => 'results#person_event'
    get '/events/:event_id/teams/:team_id/results' => 'results#team_event'
    get '/events/:event_id/teams/:team_id/results/:race_id' => 'results#team_event'
    get '/events/:event_id' => 'results#event'

    resources :events do
      resources :results
      resources :people do
        resources :results
      end
      resources :races
      resources :teams do
        resources :results
      end
    end

    get "/human_dates/:date" => "human_dates#show", constraints: { date: /.*/ }

    resources :photos

    resources :races
    get '/rider_rankings/:year' => 'competitions/competitions#show', as: :rider_rankings, type: 'rider_rankings', constraints: { year: /\d{4}/ }
    get '/rider_rankings' => 'competitions/competitions#show', as: :rider_rankings_root, type: 'rider_rankings'
    get '/ironman(/:year)' => 'competitions/ironman#index', as: :ironman


    get '/oregon_cup/rules' => 'competitions/oregon_cup#rules'
    get '/oregon_cup/races' => 'competitions/oregon_cup#races'
    get '/oregon_cup/:year' => 'competitions/oregon_cup#index', as: :oregon_cup
    get '/oregon_cup' => 'competitions/oregon_cup#index', as: :oregon_cup_root
    get "/oregon_tt_cup" => "competitions/competitions#show", type: "oregon_tt_cup"
    get '/oregon_womens_prestige_series' => 'competitions/oregon_womens_prestige_series#show'
    get '/owps' => 'competitions/oregon_womens_prestige_series#show'

    resources :password_resets

    resources :mailing_lists do
      get :confirm
      get :confirm_private_reply
      resources :posts
    end

    resources :posts

    get '/people/:person_id/results' => 'results#person', constraints: { person_id: /\d+/ }
    get '/people/:person_id/:year' => 'results#person', constraints: { person_id: /\d+/, year: /\d\d\d\d/ }, as: :person_results_year
    get '/people/:person_id' => 'results#person', constraints: { person_id: /\d+/ }
    get '/people/list' => 'people#list'
    get '/people/new_login' => 'people#new_login'
    get '/people/:id/new_login' => 'people#new_login'
    get "/people/:id/account" => redirect("/people/%{id}/edit"), constraints: { person_id: /\d+/ }, as: :account_person
    get "/people/:id/editors/:editor_id/create" => "editors#create", constraints: { id: /\d+/, editor_id: /\d+/ }, as: :create_person_editor
    get "/people/:id/editors/:editor_id/destroy" => "editors#destroy", constraints: { id: /\d+/, editor_id: /\d+/ }, as: :destroy_person_editor
    get "/people/:id/editor_requests/:editor_id/create" => "editor_requests#create", constraints: { id: /\d+/, editor_id: /\d+/ }, as: :create_person_editor_request
    get "/people/:id/editor_requests/:editor_id/destroy" => "editor_requests#destroy", constraints: { id: /\d+/, editor_id: /\d+/ }, as: :destroy_person_editor_request

    resources :people do
      post :create_login, on: :collection
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
    get '/results/:year/:discipline' => 'results#index', constraints: { year: /(19|20)\d\d/ }, as: :results_year_discipline
    get '/results/:year' => 'results#index', constraints: { year: /(19|20)\d\d/ }, as: :results_year
    get '/results/:discipline' => 'results#index'
    resources :results do
      member do
        patch :update_attribute
      end
    end
    get '/schedule/:year/calendar' => 'schedule#index', constraints: { year: /\d\d\d\d/ }
    get '/schedule/:year/calendar' => 'schedule#calendar', constraints: { year: /\d\d\d\d/ }
    get '/schedule/calendar' => 'schedule#calendar'
    get '/schedule/list/:discipline' => 'schedule#list'
    get '/schedule/:year/list/:discipline' => 'schedule#list', constraints: { year: /\d\d\d\d/ }
    get '/schedule/:year/list' => 'schedule#list', constraints: { year: /\d\d\d\d/ }
    get '/schedule/:year(/:discipline)' => 'schedule#index', constraints: { year: /\d\d\d\d/ }, as: :schedule_index
    get '/schedule/:year' => 'schedule#index', constraints: { year: /\d\d\d\d/ }
    get '/schedule/list' => 'schedule#list'
    get '/schedule/:discipline' => 'schedule#index', constraints: { discipline: /[^\d]+/ }
    get '/sanctioning_organization/:sanctioning_organization/schedule' => 'schedule#index', as: "schedule_sanctioning_organization"
    get '/schedule' => 'schedule#index', as: :schedule
    get '/region/:region(/:year)/schedule' => 'schedule#index', as: "schedule_region", constraints: { year: /\d\d\d\d/ }
    resources :single_day_events
    get '/teams/:team_id/results' => 'results#team'
    get '/teams/:team_id/:year' => 'results#team', constraints: { person_id: /\d+/, year: /\d\d\d\d/ }, as: :team_results_year
    get '/teams/:team_id' => 'results#team'
    resources :teams do
      resources :results
    end
    get '/track' => 'track#index', as: :track
    get '/track/schedule' => 'track#schedule', as: :track_schedule
    resource :person_session
    get '/unauthorized' => 'person_sessions#unauthorized', as: :unauthorized
    get '/logout' => 'person_sessions#destroy', as: :logout
    get '/login' => 'person_sessions#new', as: :login
    get '/account/logout' => 'person_sessions#destroy'
    get '/account/login' => 'person_sessions#new'
    get '/account' => 'people#account', as: :account

    get '/wsba_barr' => 'competitions/competitions#show', as: :wsba_barr_root, type: 'wsba_barr'
    get '/wsba_barr/:year' => 'competitions/competitions#show', as: :wsba_barr, type: 'wsba_barr', constraints: { year: /\d{4}/ }
    get '/wsba_masters_barr' => 'competitions/competitions#show', as: :wsba_masters_barr_root, type: 'wsba_masters_barr'
    get '/wsba_masters_barr/:year' => 'competitions/competitions#show', as: :wsba_masters_barr, type: 'wsba_masters_barr', constraints: { year: /\d{4}/ }

    get '/' => 'home#index', as: :root
    resource :home, controller: :home

    get '*path', to: 'pages#show', constraints: Pages::Constraint.new

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
end
