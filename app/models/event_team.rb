class EventTeam < ActiveRecord::Base
  belongs_to :event
  belongs_to :team

  has_many :event_team_memberships, dependent: :restrict_with_error

  validates_presence_of :event
  validates_presence_of :team

  accepts_nested_attributes_for :team

  def name
    team.try(:name)
  end

  def people
    event_team_memberships.map(&:person)
  end

  def team_attributes=(attrs)
    if Team.where(name: attrs[:name]).exists?
      self.team = Team.where(name: attrs[:name]).first
    else
      super
    end
  end
end
