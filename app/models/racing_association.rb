# TODO Should this be in database as full-fledged ActiveRecord?
# bar_point_schedule should be stored in the database with the BAR?
class RacingAssociation

  attr_accessor :name, :short_name, :state, :email, :membership_email
  attr_accessor :masters_age
  attr_accessor :gender_specific_numbers, :rental_numbers, :bmx_numbers, :default_discipline, :cx_memberships
  attr_accessor :competitions
  attr_accessor :administrator_tabs
  attr_accessor :award_cat4_participation_points, :cat4_womens_race_series_points, :cat4_womens_race_series_category
  attr_accessor :show_license, :show_only_association_sanctioned_races_on_calendar, :show_calendar_view, :flyers_in_new_window
  attr_accessor :show_practices_on_calendar
  attr_accessor :always_insert_table_headers
  attr_accessor :show_events_velodrome
  attr_accessor :usac_region
  attr_accessor :country_code
  attr_accessor :default_sanctioned_by
  attr_accessor :usac_results_format
  attr_accessor :eager_match_on_license
  attr_accessor :add_members_from_results
  attr_accessor :show_events_sanctioning_org_event_id
  attr_accessor :exempt_team_categories
  attr_accessor :ssl
  attr_accessor :now
  
  def initialize
    @cx_memberships = false
    @masters_age = 35
    @show_license = true
    @show_events_velodrome = true
    @show_only_association_sanctioned_races_on_calendar = true
    @show_practices_on_calendar = false
    @email = "scott@butlerpress.com"
    @membership_email = @email
    @competitions = Set.new([:age_graded_bar, :bar, :ironman, :overall_bar, :team_bar])
    @administrator_tabs = Set.new([ 
      :schedule, :first_aid, :people, :teams, :velodromes, :categories, :cat4_womens_race_series, :article_categories, :articles, :pages 
    ])
    @award_cat4_participation_points = true
    @usac_region = "North West"
    @usac_results_format = false
    @country_code = "US"
    @eager_match_on_license = false
    @add_members_from_results = true
    @show_events_sanctioning_org_event_id = false
    @ssl = false
  end
  
  def bmx_numbers?
    @bmx_numbers
  end
  
  def cx_memberships?
    @cx_memberships
  end
  
  def default_discipline
    @default_discipline ||= "Road"
  end
  
  def default_sanctioned_by
    @default_sanctioned_by ||= short_name
  end

  def default_sanctioned_by
    @default_sanctioned_by ||= short_name
  end

  def gender_specific_numbers?
    @gender_specific_numbers
  end
  
  def flyers_in_new_window?
    @flyers_in_new_window
  end
  
  def always_insert_table_headers?
    @always_insert_table_headers
  end
  
  def show_calendar_view?
    @show_calendar_view
  end
  
  def show_events_velodrome?
    @show_events_velodrome
  end
  
  def show_practices_on_calendar?
    @show_practices_on_calendar
  end

  def show_only_association_sanctioned_races_on_calendar?
    @show_only_association_sanctioned_races_on_calendar
  end
  
  def award_cat4_participation_points?
    @award_cat4_participation_points
  end

  def usac_results_format?
    @usac_results_format
  end
  
  def eager_match_on_license?
    @eager_match_on_license
  end
  
  def add_members_from_results?
    @add_members_from_results
  end

  def show_events_sanctioning_org_event_id?
    @show_events_sanctioning_org_event_id
  end
  
  def ssl?
    @ssl
  end
  
  # Defaults to Time.now, but can be explicitly set for tests or data cleanup
  def now
    @now || Time.zone.now
  end
  
  # Returns now.to_date, which is the same as Date.today. But can be explicitly set for tests or data cleanup.
  def today
    now.to_date
  end
  
  # Returns now.to_date.year, which is the same as Date.today. But can be explicitly set for tests or data cleanup.
  def year
    now.to_date.year
  end
  
  # "Membership year." Used for race number export, schedule, and renewals. Returns current year until December.
  # On and after December 1, returns the next year.
  def effective_year
    if now.month < 12
      now.year
    else
      now.year + 1
    end
  end
  
  def effective_today
    if now.month < 12
      Date.new(now.year)
    else
      Date.new(now.year + 1)
    end
  end
  
  # Date.today.year + 1 unless +now+ is set.
  def next_year
    now.year + 1
  end
  
  def priority_country_options
    if country_code == "US"
      [ ['United States', 'US'], ['Canada', 'CA'] ]
    else
      [ ['Canada', 'CA'], ['United States', 'US'] ]
    end
  end

  def to_s
    "#<RacingAssociation #{short_name} #{name}>"
  end
end
