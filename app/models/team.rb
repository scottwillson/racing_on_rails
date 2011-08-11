# Bike racing team of People
#
# Like People, Teams may have many alternate names. These are modelled as Aliases. Historical names from previous years are stored as Names.
#
# Team names must be unique
class Team < ActiveRecord::Base
  include Names::Nameable
  include Export::Teams

  before_save :destroy_shadowed_aliases
  after_save :add_alias_for_old_name
  after_save :reset_old_name
  before_destroy :ensure_no_results
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :aliases
  belongs_to :created_by, :polymorphic => true
  has_many :events
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
  
  def Team.find_all_by_name_like(name, limit = 100)
    name_like = "%#{name}%"
    Team.all(
      :conditions => ['teams.name like ? or aliases.name like ?', name_like, name_like], 
      :include => :aliases,
      :limit => limit,
      :order => 'teams.name'
    )
  end
  
  def teams_with_same_name
    teams = Team.find_all_by_name(self.name) | Alias.find_all_teams_by_name(self.name)
    teams.reject! { |team| team == self }
    teams
  end

  def ensure_no_results
    return true if results.empty?

    errors.add :base, "Cannot delete team with results. #{name} has #{results.count} results."
    false
  end
  
  # If name changes to match existing alias, destroy the alias
  def destroy_shadowed_aliases
    Alias.destroy_all(['name = ?', name])
  end
  
  def add_alias_for_old_name
    if !new_record? && 
      @old_name.present? && 
      name.present? && 
      @old_name.casecmp(name) != 0 && 
      !Alias.exists?(['name = ? and team_id = ?', @old_name, id]) &&
      !Team.exists?(["name = ?", @old_name])

      new_alias = Alias.create!(:name => @old_name, :team => self)
      unless new_alias.save
        logger.error("Could not save alias #{new_alias}: #{new_alias.errors.full_messages.join(", ")}")
      end
      new_alias
    end
  end
  
  # Otherwise, if we change name in memory more than once, @old_name will be out of date
  def reset_old_name
    @old_name = name
  end
  
  def has_alias?(alias_name)
    aliases.detect { |a| a.name.casecmp(alias_name) == 0 }
  end

  # Moves another Team's aliases, results, and people to this Team,
  # and delete the other Team.
  # Also adds the other Team's name as a new alias
  def merge(team)
    raise(ArgumentError, 'Cannot merge nil team') unless team
    raise(ArgumentError, 'Cannot merge team onto itself') if team == self

    Team.transaction do
      events_with_results = team.results.collect do |result|
        event = result.event
        event.disable_notification!
        event
      end || []
      
      team.create_team_for_historical_results!
      
      aliases << team.aliases
      events << team.events
      results << team.results(true)
      people << team.people
      Team.delete(team.id)
      existing_alias = aliases.detect{ |a| a.name.casecmp(team.name) == 0 }
      if existing_alias.nil? && Team.find_all_by_name(team.name).empty?
        aliases.create(:name => team.name) 
      end
      events_with_results.each do |event|
        event.enable_notification!
      end
    end
  end
  
  # Preserve team names in old results by creating a new Team for them, and moving the results.
  #
  # Results are preserved by creating a new Team from the most recent Name. If a Team
  # already exists with the Name's name, results will move to existing Team.
  # This may be unxpected, can't think of a better way to handle it in this model.
  def create_team_for_historical_results!
    name = names.sort_by(&:year).reverse!.first
    
    if name
      team = Team.find_or_create_by_name(name.name)
      results.each do |result|
        team.results << result if result.date.year <= name.year
      end
      
      name.destroy
      names.each do |name|
        team.names << name unless name == name
      end
    end
  end
  
  def member_in_year?(date = Date.today)
    member
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
