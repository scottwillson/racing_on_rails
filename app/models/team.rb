# Bike racing team of Racers
#
# Like Racers, Teams may have many alternate  names. These are modelled as Aliases
#
# Team names must be unique
class Team < ActiveRecord::Base

  include Dirty
  
  before_save :add_old_name
  before_save :destroy_shadowed_aliases
  after_save :add_alias_for_old_name
  after_save :reset_old_name
  
  validates_presence_of :name
  validate :no_duplicates
  
  has_many :aliases
  has_many :names
  has_many :racers
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
  
  def no_duplicates
    existing_team = Team.find_by_name(name)
    if existing_team and ((existing_team.id == id and existing_team.name.casecmp(name) != 0) or (existing_team.id != id and name == existing_team.name))
      errors.add('name', "'#{name}' already exists")
    end
  end

  # Remember names from previous years. Keeps the correct name on old results without creating additional teams.
  # TODO This is a bit naive, needs validation, and more tests
  def add_old_name
    if !@old_name.blank? && results_before_this_year?
      self.names.create(:name => @old_name, :year => Date.today.year - 1)
    end
  end
  
  def results_before_this_year?
    # Exists? doesn't support joins
    count = Team.count_by_sql([%Q{
      select results.id from teams, results, races, standings, events 
      where teams.id = ? and teams.id = results.team_id 
        and results.race_id = races.id
        and races.standings_id  = standings.id
        and standings.event_id = events.id and events.date < ? limit 1
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
  
  # Otherwise, if we change name in memory more than once, @old_name will be out of date
  def reset_old_name
    @old_name = name
  end
  
  def has_alias?(alias_name)
    aliases.detect {|a| a.name.casecmp(alias_name) == 0}
  end

  # Moves another Team's aliases, results, and racers to this Team,
  # and delete the other Team.
  # Also adds the other Team's name as a new alias
  def merge(team)
    raise(ArgumentError, 'Cannot merge nil team') unless team
    raise(ArgumentError, 'Cannot merge team onto itself') if team == self

    Team.transaction do
      events = team.results.collect do |result|
        event = result.race.standings.event
        event.disable_notification!
        event
      end
      begin
        save!
        aliases << team.aliases
        results << team.results
        racers << team.racers
        Team.delete(team.id)
        existing_alias = aliases.detect{|a| a.name.casecmp(team.name) == 0}
        if existing_alias.nil? and Team.find_all_by_name(team.name).empty?
          aliases.create(:name => team.name) 
        end
      ensure
        if events
          events.each do |event|
            event.reload
            event.enable_notification!
          end
        end
      end
    end
  end
  
  def member_in_year?(date = Date.today)
    member
  end
  
  # Team names change over time
  def name(date = nil)
    return read_attribute(:name) unless date
    
    # TODO Tune this
    name_for_date = self.names.detect { |n| n.year == date.year }
    if name_for_date
      name_for_date.name
    else
      read_attribute(:name)
    end
  end
  
  def name=(value)
    @old_name = name unless @old_name
    self[:name] = value
  end
  
  def to_s
    "#<Team #{id} '#{name}'>"
  end

end
