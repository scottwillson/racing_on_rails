class EventTeamMembership < ActiveRecord::Base
  belongs_to :event_team
  belongs_to :person

  validates_presence_of :event_team
  validates_presence_of :person

  validates_uniqueness_of :person, scope: :event_team
  validate :uniqueness_of_event

  accepts_nested_attributes_for :event_team
  accepts_nested_attributes_for :person

  def event
    event_team.try(:event)
  end

  def event_name
    event.try(:full_name)
  end

  def person_attributes=(attrs)
    if person && !person.new_record?
      true
    else
      super
    end
  end

  def person_name
    person.try(:name)
  end

  def team
    event_team.try(:team)
  end

  def team_name
    team.try(:name)
  end

  def uniqueness_of_event
    if person && person.event_team_memberships.reject { |m| m == self }.map(&:event).include?(event)
      errors.add :event_team, "Already on a team for #{event.name}"
    end
  end
end
