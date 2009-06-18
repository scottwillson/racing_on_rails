# Alternate name for a Person or Team. Example: Erik Tonkin might have aliases of 'Eric Tonkin,' and 'E. Tonkin'
# Must belong to either a Person or Team, but not both. Used by Result when importing results from Excel.
class Alias < ActiveRecord::Base
  belongs_to :person
  belongs_to :team
  
  validates_presence_of :name
  validate :person_or_team
  validate :cannot_shadow_person
  validate :cannot_shadow_team
  
  def Alias.find_all_people_by_name(name)
    aliases = Alias.find(
      :all, 
      :conditions => ['name = ? and person_id is not null', name],
      :include => :person
    )
    aliases.collect do |person_alias|
      person_alias.person
    end
  end
  
  def Alias.find_all_teams_by_name(name)
    aliases = Alias.find(
      :all, 
      :conditions => ['aliases.name = ? and team_id is not null', name],
      :include => :team
    )
    aliases.collect do |team_alias|
      team_alias.team
    end
  end
  
  def person_or_team
    unless (person and !team) or (!person and team)
      errors.add('person or team', 'Must have exactly one person or team')
    end
  end
  
  def cannot_shadow_person
    if Person.exists?(["trim(concat(first_name, ' ', last_name)) = ?", name])
      errors.add('name', "Person named '#{name}' already exists. Cannot create alias that shadows a person's real name.")
    end
  end
  
  def cannot_shadow_team
    if Team.exists?(['name = ?', name])
      errors.add('name', "Team named '#{name}' already exists. Cannot create alias that shadows a team's real name.")
    end
  end

  def to_s
    "<#{self.class.name} #{self[:id]} #{self[:name]} #{self[:person_id]} #{self[:team_id]}>"
  end
end
