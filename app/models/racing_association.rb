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

  attr_accessor :person

  serialize :administrator_tabs
  serialize :cat4_womens_race_series_points
  serialize :competitions
  serialize :membership_email
  serialize :sanctioning_organizations
  
  default_value_for :administrator_tabs do
    Set.new([ 
      :schedule, :first_aid, :people, :teams, :velodromes, :categories, :cat4_womens_race_series, :article_categories, :articles, :pages 
    ])
  end
  
  default_value_for :cat4_womens_race_series_category do
    Category.find_or_create_by_name "Category 4 Women"
  end
  
  default_value_for :competitions do
    Set.new([:age_graded_bar, :bar, :ironman, :overall_bar, :team_bar])
  end
  
  # String
  default_value_for :default_sanctioned_by do |r|
    r.short_name
  end

  default_value_for :membership_email do |r|
    r.email
  end
  
  default_value_for :sanctioning_organizations do
    [ "FIAC", "CBRA", "UCI", "USA Cycling" ]
  end
  
  def self.current
    @current ||= RacingAssociation.first || RacingAssociation.create
  end

  def self.current=(value)
    @current = value
  end
  
  # Person record for RacingAssociation
  def person
    @person ||= Person.find_or_create_by_name(short_name)
  end
  
  def person_id
    @person_id ||= person.id
  end
  
  # Returns now.beginning_of_day, which is the same as Time.zone.today
  def today
    Time.zone.now.to_date
  end
  
  # Returns now.year, which is the same as Time.zone.today.
  def year
    Time.zone.now.year
  end
  
  # "Membership year." Used for race number export, schedule, and renewals. Returns current year until December.
  # On and after December 1, returns the next year.
  def effective_year
    if next_year_start_at
      if Time.zone.now < next_year_start_at
        return Time.zone.now.year
      elsif Time.zone.now >= next_year_start_at
        return Time.zone.now.year + 1
      elsif 1.year.from_now > next_year_start_at && Time.zone.now.month >= 12
        return Time.zone.now.year + 1
      end
    else
      if Time.zone.now.month == 12
        return Time.zone.now.year + 1
      end
    end
    
    Time.zone.now.year
  end
  
  def effective_today
    Date.new(effective_year)
  end
  
  # Time.zone.today.year + 1 unless +now+ is set.
  def next_year
    if effective_year == Time.zone.now.year
      effective_year + 1
    else
      effective_year
    end
  end
  
  def cyclocross_season?
    RacingAssociation.current.today >= cyclocross_season_start.to_date && RacingAssociation.current.today <= cyclocross_season_end.to_date
  end
  
  def cyclocross_season_start
    Time.zone.local(Time.zone.now.year, 9, 2).beginning_of_day
  end
  
  def cyclocross_season_end
    Time.zone.local(Time.zone.now.year, 12, 16).end_of_day
  end

  def rental_numbers
    if rental_numbers_start && rental_numbers_end
      rental_numbers_start..rental_numbers_end
    else
      nil
    end
  end

  def rental_numbers=(value)
    if value.nil?
      self.rental_numbers_start = nil
      self.rental_numbers_end = nil
    else
      self.rental_numbers_start = rental_numbers.first
      self.rental_numbers_end = rental_numbers.last
    end
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
