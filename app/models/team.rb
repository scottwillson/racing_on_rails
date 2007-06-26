# Bike racing team of Racers
#
# Like Racers, Teams may have many alternate  names. These are modelled as Aliases
#
# Team names must be unique
class Team < ActiveRecord::Base

  include Dirty
  
  validates_presence_of :name
  validate :no_duplicates
  
  has_many :aliases
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
  
  # TODO Consider aliases
  def no_duplicates
    existing_team = Team.find_by_name_or_alias(name)
    if existing_team and ((existing_team.id == id and existing_team.name.casecmp(name) != 0) or (existing_team.id != id and name == existing_team.name))
      errors.add('name', "'#{name}' already exists")
    end
  end
  
  def has_alias?(alias_name)
    aliases.detect {|a| a.name.casecmp(alias_name) == 0}
  end
  
  def destroy_alias(alias_name)
    old_alias = aliases.detect{|a| a.name.casecmp(alias_name) == 0}
    old_alias.destroy
  end
  
  def create_alias(alias_name)
    old_alias = aliases.detect{|a| a.name.casecmp(alias_name) == 0}
    aliases.delete(old_alias) if old_alias

    # Alias may belong to a different team
    old_alias = Alias.find(:first, :conditions => ['name = ? and racer_id is null', alias_name])
    old_alias.destroy if old_alias
    
    new_alias = aliases.create(:name => alias_name)
    for error in new_alias.errors
      errors.add('aliases', error)
    end
  end
  
  # Moves another Team's aliases, results, and racers to this Team,
  # and delete the other Team.
  # Also adds the other Team's name as a new alias
  def merge(team)
    if team == self
      raise(ArgumentError, 'Cannot merge team onto itself')
    end
    if team.nil?
      raise(ArgumentError, 'Cannot merge nil team')
    end
    Team.transaction do
      begin
        events = team.results.collect do |result|
          event = result.race.standings.event
          event.disable_notification!
          event
        end
        aliases << team.aliases
        results << team.results
        racers << team.racers
        Team.delete(team.id)
        existing_alias = aliases.detect{|a| a.name == team.name}
        aliases.create(:name => team.name) unless existing_alias or Alias.find_by_name(team.name) 
        save!
      ensure
        events.each do |event|
          event.reload
          event.enable_notification!
        end
      end
    end
  end
  
  def member_in_year?(date = Date.today)
    member
  end
  
  def to_s
    "#<Team #{id} '#{name}'>"
  end

end
