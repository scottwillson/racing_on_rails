class EventTeamMembership < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
  belongs_to :team

  validates_presence_of :event
  validates_presence_of :person
  validates_presence_of :team

  accepts_nested_attributes_for :team

  def team_attributes=(attr)
    team_name = attr[:name].try(:strip)

    if team_name.present?
      self.team = Team.where(name: team_name).first_or_create
    else
      super
    end
  end
end
