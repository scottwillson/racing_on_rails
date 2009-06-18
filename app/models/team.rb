# Bike racing team of People
#
# Like People, Teams may have many alternate  names. These are modelled as Aliases
#
# Team names must be unique
class Team < ActiveRecord::Base

  before_save :add_historical_name
  before_save :destroy_shadowed_aliases
  after_save :add_alias_for_old_name
  after_save :reset_old_name
  before_destroy :ensure_no_results
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :aliases
  belongs_to :created_by, :polymorphic => true
  has_many :historical_names, :order => "year"
  has_many :people
  has_many :results

  def Team.find_by_name_or_alias(name)
    team = Team.find_by_name(name)
    if team.nil?
      team_alias = Alias.find_by_name(name)
      if team_alias
        team = team_alias.team
      end
    end
    team
  end
  
  def Team.find_by_name_or_alias_or_create(name)
    team = find_by_name_or_alias(name)
    if team.nil?
      team = Team.create(:name => name)
    end
    team
  end
  
  def teams_with_same_name
    teams = Team.find_all_by_name(self.name) | Alias.find_all_teams_by_name(self.name)
    teams.reject! { |team| team == self }
    teams
  end

  def ensure_no_results
    return true if results.empty?

    errors.add_to_base("Cannot delete team with results. #{name} has #{results.count} results.")
    false
  end
  
  def results_before_this_year?
    # Exists? doesn't support joins
    count = Team.count_by_sql([%Q{
      select results.id from teams, results, races, events 
      where teams.id = ? and teams.id = results.team_id 
        and results.race_id = races.id
        and races.event_id = events.id and events.date < ? limit 1
    }, self.id, Date.today.beginning_of_year])
    count > 0
  end
  
  # If name changes to match existing alias, destroy the alias
  def destroy_shadowed_aliases
    Alias.destroy_all(['name = ?', name])
  end
  
  def add_alias_for_old_name
    if !new_record? && 
      !@old_name.blank? && 
      !name.blank? && 
      @old_name.casecmp(name) != 0 && 
      !Alias.exists?(['name = ? and team_id = ?', @old_name, id]) &&
      !Team.exists?(["name = ?", @old_name])

      Alias.create!(:name => @old_name, :team => self)
    end
  end

  # Remember names from previous years. Keeps the correct name on old results without creating additional teams.
  # TODO This is a bit naive, needs validation, and more tests
  def add_historical_name
    last_year = Date.today.year - 1
    if !@old_name.blank? && results_before_this_year? && !self.historical_names.any? { |name| name.year == last_year }
      self.historical_names.create(:name => @old_name, :year => last_year)
    end
  end
  
  # Otherwise, if we change name in memory more than once, @old_name will be out of date
  def reset_old_name
    @old_name = name
  end
  
  def has_alias?(alias_name)
    aliases.detect {|a| a.name.casecmp(alias_name) == 0}
  end

  # Moves another Team's aliases, results, and people to this Team,
  # and delete the other Team.
  # Also adds the other Team's name as a new alias
  def merge(team)
    raise(ArgumentError, 'Cannot merge nil team') unless team
    raise(ArgumentError, 'Cannot merge team onto itself') if team == self

    Team.transaction do
      events = team.results.collect do |result|
        event = result.event
        event.disable_notification!
        event
      end || []
      
      team.create_team_for_historical_results!
      
      aliases << team.aliases
      results << team.results(true)
      people << team.people
      Team.delete(team.id)
      existing_alias = aliases.detect{ |a| a.name.casecmp(team.name) == 0 }
      if existing_alias.nil? && Team.find_all_by_name(team.name).empty?
        aliases.create(:name => team.name) 
      end
      events.each do |event|
        event.enable_notification!
      end
    end
  end
  
  # Preserve team names in old results by creating a new Team for them, and moving the results.
  #
  # Results are preserved by creating a new Team from the most recent HistoricalName. If a Team
  # already exists with the HistoricalName's name, results will move to existing Team.
  # This may be unxpected, can't think of a better way to handle it in this model.
  def create_team_for_historical_results!
    historical_name = historical_names.sort_by(&:year).reverse!.first
    
    if historical_name
      team = Team.find_or_create_by_name(historical_name.name)
      results.each do |result|
        team.results << result if result.date.year <= historical_name.year
      end
      
      historical_name.destroy
      historical_names.each do |name|
        team.historical_names << name unless name == historical_name
      end
    end
  end
  
  def member_in_year?(date = Date.today)
    member
  end
  
  # Team names change over time
  def name(date_or_year = nil)
    return read_attribute(:name) unless date_or_year && !self.historical_names.empty?
    
    # TODO Tune this
    if date_or_year.is_a? Integer
      year = date_or_year
    else
      year = date_or_year.year
    end
    
    # Assume historical_names always sorted
    if year <= self.historical_names.first.year
      return self.historical_names.first.name
    elsif year >= self.historical_names.last.year && year < Date.today.year
      return self.historical_names.last.name
    end
    
    name_for_year = self.historical_names.detect { |n| n.year == year }
    if name_for_year
      name_for_year.name
    else
      read_attribute(:name)
    end
  end
  
  def name=(value)
    @old_name = name unless @old_name
    self[:name] = value
  end
  
  def created_from_result?
    !created_by.nil? && created_by.kind_of?(Event)
  end
  
  def updated_after_created?
    created_at && updated_at && ((updated_at - created_at) > 1.hour) && updated_by
  end

  def to_s
    "#<Team #{id} '#{name}'>"
  end
end
