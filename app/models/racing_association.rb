# OBRA, WSBA, USA Cycling, etc …
# Many defaults. Override in environment.rb. Stored in RacingAssociation.current constant.
# bar_point_schedule should be stored in the database with the BAR?
#
# cx_memberships? Offers cyclocross memberships
# eager_match_on_license? Trust license number in results? Use it to match People instead of name.
# search_results_limit: Limit number of people, teams, etc. returned in search
class RacingAssociation < ActiveRecord::Base
  # TODO bmx_numbers? Shouldn't this be in disciplines?

  belongs_to :cat4_womens_race_series_category, :class_name => "Category"

  attr_accessor :now
  attr_accessor :person
  attr_accessor :rental_numbers

  serialize :administrator_tabs
  serialize :cat4_womens_race_series_points
  serialize :competitions
  serialize :exception_recipients
  serialize :sanctioning_organizations
  
  default_value_for :administrator_tabs do
    Set.new([ 
      :schedule, :first_aid, :people, :teams, :velodromes, :categories, :cat4_womens_race_series, :article_categories, :articles, :pages 
    ])
  end
  
  default_value_for :competitions do
    Set.new([:age_graded_bar, :bar, :ironman, :overall_bar, :team_bar])
  end
  
  # String
  default_value_for :default_sanctioned_by do |r|
    r.short_name
  end
  
  default_value_for :exception_recipients do
    "scott.willson@gmail.com"
  end
  
  default_value_for :rental_numbers do |r|
    (r.rental_numbers_start)..(r.rental_numbers_end)
  end
  
  default_value_for :sanctioning_organizations do
    [ "FIAC", "CBRA", "UCI", "USA Cycling" ]
  end
  
  def self.current
    @current ||= RacingAssociation.first
  end

  def self.current=(value)
    @current = value
  end
  
  # Person record for RacingAssociation
  def person
    @person ||= Person.find_or_create_by_name(short_name)
  end

  # Defaults to Time.now, but can be explicitly set for tests or data cleanup
  def now
    @now || Time.zone.now
  end
  
  # Returns now.beginning_of_day, which is the same as Date.today. But can be explicitly set for tests or data cleanup.
  def today
    now.beginning_of_day
  end
  
  # Returns now.year, which is the same as Date.today. But can be explicitly set for tests or data cleanup.
  def year
    now.year
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
