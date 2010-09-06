class CreateRacingAssociation < ActiveRecord::Migration
  def self.up
    case ActiveRecord::Base.configurations["production"]["database"]
    when "aba"
      racing_association = RacingAssociation.create!(
        :name => "Alberta Bicycle Association",
        :short_name => "ABA",
        :state => "AB",
        :country_code => "CA",
        :rental_numbers => 0..0,
        :show_only_association_sanctioned_races_on_calendar => true,
        :show_calendar_view => true,
        :show_events_velodrome => false,
        :flyers_in_new_window => true,
        :bmx_numbers => true,
        :competitions => Set.new,
        :administrator_tabs => Set.new([ 
          :schedule, :people, :teams, :categories, :pages 
        ]),
        :sanctioning_organizations => [ "ABA", "CCA", "UCI" ],
        :static_host => "albertabicycle.ab.ca/dev"
      )
      
      case Rails.env
      when "staging"
        racing_association.rails_host = "staging.aba.obra.org"
      when "production"
        racing_association.rails_host = "app.albertabicycle.ab.ca"
      end
      racing_association.save!

    when "atra"
      racing_association = RacingAssociation.create!(
        :name => "American Track Racing Association",
        :short_name => "ATRA",
        :state => "",
        :default_discipline => "Track",
        :rental_numbers => 0..99,
        :show_only_association_sanctioned_races_on_calendar => true,
        :show_events_velodrome => true,
        :competitions => Set.new([ :atra_points_series ]),
        :administrator_tabs => Set.new([ 
          :schedule, :people, :teams, :velodromes, :categories, :pages
        ]),
        :sanctioning_organizations => [ "ATRA", "UCI", "USA Cycling" ],
        :static_host => "www.raceatra.com"
      )
      
      case Rails.env
      when "production"
        racing_association.rails_host = "raceatra.com"
      end
      racing_association.save!

    when "albert_production"
      racing_association = RacingAssociation.create!(
        :name => "Montana Bicycle Racing Association",
        :short_name => "MBRA",
        :state => "MT",
        :masters_age => 40,
        :exception_recipients => %w(al.pendergrass@gmail.com scott.willson@gmail.com),
        :show_only_association_sanctioned_races_on_calendar => true,
        :show_practices_on_calendar => true,
        :show_events_velodrome => false,
        :rental_numbers => 51..99,
        :usac_region => "Mountain",
        :usac_results_format => true,
        :default_sanctioned_by => "USA Cycling",
        :show_events_sanctioning_org_event_id => true,
        :competitions => Set.new([:bar, :team_bar, :mbra_bar, :mbra_team_bar]),
        :administrator_tabs => Set.new([ 
          :schedule, :first_aid, :people, :teams, :velodromes, :categories, :cat4_womens_race_series, :article_categories, :articles, :pages 
        ]),
        :eager_match_on_license => true,
        :include_multiday_events_on_schedule => true,
        :sanctioning_organizations => [ "UCI", "USA Cycling" ],
        :show_all_teams_on_public_page => true,
        :weeks_of_recent_results => 4,
        :weeks_of_upcoming_events => 5
      )
      
      case Rails.env
      when "production"
        racing_association.rails_host = "www.montanacycling.net"
        racing_association.static_host = "www.montanacycling.net"
      when "staging"
        racing_association.rails_host = "staging.montanacycling.net"
        racing_association.static_host = "staging.montanacycling.net"
      end
      racing_association.save!

    when "obra"
      racing_association = RacingAssociation.create!(
        :name => "Oregon Bicycle Racing Association",
        :short_name => "OBRA",
        :state => "OR",
        :cx_memberships => true,
        :masters_age => 30,
        :rental_numbers => 0..99,
        :show_events_velodrome => false,
        :show_only_association_sanctioned_races_on_calendar => true,
        :always_insert_table_headers => true,
        :add_members_from_results => false,
        :competitions => Set.new([
          :age_graded_bar, :bar, :cat4_womens_race_series, :cross_crusade_series_standings, :ironman, :oregon_cup, :overall_bar, :tabor_series_standings, :team_bar]),
        :administrator_tabs => Set.new([ 
          :first_aid, :people, :teams, :categories, :cat4_womens_race_series, :pages 
        ]),
        :award_cat4_participation_points => false,
        :cat4_womens_race_series_points => [ 0, 100, 70, 50, 40, 36, 32, 28, 24, 20, 16 ],
        :ssl => true,
        :membership_email => %w(kenji@obra.org),
        :sanctioning_organizations => [ "ATRA", "FIAC", "OBRA", "UCI", "USA Cycling" ],
        :weeks_of_recent_results => 1,
        :weeks_of_upcoming_events => 2
      )

      case Rails.env
      when "production"
        racing_association.rails_host = "obra.org"
        racing_association.static_host = "www.obra.org"
      when "staging"
        racing_association.rails_host = "app.obra.butlerpress.com"
        racing_association.static_host = "www.obra.butlerpress.com"
      when "performance"
        racing_association.rails_host = "obra.org"
        racing_association.static_host = "www.obra.org"
      when "development"
        racing_association.static_host = "www.obra.org"
      end
      racing_association.save!

    when "wsba"
      racing_association = RacingAssociation.create!(
        :gender_specific_numbers => true,
        :name => "Washington State Bicycle Association",
        :short_name => "WSBA",
        :state => "WA",
        :show_license => true,
        :show_events_velodrome => false,
        :rental_numbers => 2000..2999,
        :flyers_in_new_window => false,
        :competitions => Set.new([:cascade_cross_series_standings, :cat4_womens_race_series, :rider_rankings]),
        :administrator_tabs => Set.new([ 
          :schedule, :people, :teams, :categories, :cat4_womens_race_series, :pages 
        ]),
        :exempt_team_categories => ["Masters Men C", "Masters Men D", "Masters Women A", "Masters Women B", "Women Cat 1-2", "Women Cat 3", "Women Cat 4"],
        :eager_match_on_license => true,
        :sanctioning_organizations => [ "USA Cycling" ],
        :exception_recipients => %w(scott.willson@gmail.com ryan@cyclocrazed.com)
      )

      case Rails.env
      when "production"
        racing_association.rails_host = "app.wsbaracing.com"
        racing_association.static_host = "static.wsbaracing.com"
      when "staging"
        racing_association.rails_host = "wsba.butlerpress.com"
        racing_association.static_host = "wsba.butlerpress.com"
      end
      racing_association.save!

    when "racing_on_rails_production"
      # Use defaults
      RacingAssociation.create!
    else
      "Don't recognize this racing association"
    end
  end

  def self.down
  end
end
