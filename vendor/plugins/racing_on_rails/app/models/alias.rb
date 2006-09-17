class Alias < ActiveRecord::Base
  belongs_to :racer
  belongs_to :team
  
  validates_presence_of :name
  validate :racer_or_team
  
  def Alias.find_all_racers_by_name(name)
    Alias.find_all_by_name(name).collect do |racer_alias|
      racer_alias.racer
    end
  end
  
  def racer_or_team
    unless (racer and !team) or (!racer and team)
      errors.add('racer or team', 'Must have exactly one racer or team')
    end
  end

  def to_s
    "<#{self.class.name} #{self[:id]} #{self[:name]} #{self[:racer_id]} #{self[:team_id]}>"
  end
end
