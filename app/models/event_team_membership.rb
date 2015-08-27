class EventTeamMembership < ActiveRecord::Base
  belongs_to :event_team
  belongs_to :person

  validates_presence_of :event_team
  validates_presence_of :person

  accepts_nested_attributes_for :event_team

  def event
    event_team.try(:event)
  end

  def event_name
    event.try(:full_name)
  end

  def team
    event_team.try(:team)
  end

  def team_name
    team.try(:name)
  end

  #
  # def event_team_attributes=(attr)
  #   team_name = attr[:team][:name].try(:strip)
  #
  #   if team_name.present?
  #     self.event_team = EventTeam.includes(:team).where(teams: { name: team_name }).first_or_create
  #   else
  #     super
  #   end
  # end
end
