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
  
  def to_s
    "<Team #{id} '#{name}'>"
  end

end
