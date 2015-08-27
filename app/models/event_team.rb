class EventTeam < ActiveRecord::Base
  belongs_to :event
  belongs_to :team

  has_many :event_team_memberships

  validates_presence_of :event
  validates_presence_of :team

  accepts_nested_attributes_for :team

  def name
    team.try(:name)
  end

  def people
    event_team_memberships.map(&:person)
  end
end
