# Alternate name for a Person or Team. Example: Erik Tonkin might have aliases of 'Eric Tonkin,' and 'E. Tonkin'
# Must belong to either a Person or Team, but not both. Used by Result when importing results from Excel.
# Aliases cannot be the same ("shadow") as Person#name or Team#name.
# This could probably be combined with Name.
class Alias < ActiveRecord::Base
  include Export::Aliases
  belongs_to :person
  belongs_to :team

  validates_presence_of :name
  validate :person_or_team
  validate :cannot_shadow_person
  validate :cannot_shadow_team

  def self.find_all_people_by_name(name)
    Alias.includes(:person).where("aliases.name" => name).where("person_id is not null").map(&:person)
  end

  def self.find_all_teams_by_name(name)
    logger.debug "Alias find_all_teams_by_name #{name}"
    Alias.includes(:team).where("aliases.name" => name).where("team_id is not null").map(&:team)
  end

  def person_or_team
    unless (person && !team) || (!person && team)
      errors.add "person or team", "Must have exactly one person or team"
    end
  end

  def to_s
    "<#{self.class.name} #{self[:id]} #{self[:name]} #{self[:person_id]} #{self[:team_id]}>"
  end


  private

  def cannot_shadow_person
    if person_id && Person.where(name: name).exists?
      errors.add('name', "Person named '#{name}' already exists. Cannot create alias that shadows a person's real name.")
    end
  end

  def cannot_shadow_team
    if team_id && Team.where(name: name).exists?
      errors.add('name', "Team named '#{name}' already exists. Cannot create alias that shadows a team's real name.")
    end
  end
end
