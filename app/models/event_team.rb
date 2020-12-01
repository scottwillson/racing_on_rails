# frozen_string_literal: true

class EventTeam < ApplicationRecord
  belongs_to :event
  belongs_to :team

  has_many :event_team_memberships, dependent: :restrict_with_error

  validates :event, presence: true
  validates :team, presence: true

  accepts_nested_attributes_for :team

  def create_and_join(person)
    if save
      event_team_memberships.create person: person if !event.editable_by?(person) && person.event_team_memberships.none? { |m| m.event == event }
      true
    else
      false
    end
  end

  def name
    team.try(:name)
  end

  def people
    event_team_memberships.map(&:person)
  end

  def team_attributes=(attrs)
    attrs[:name] = attrs[:name].try(:strip)
    if Team.exists?(name: attrs[:name])
      self.team = Team.where(name: attrs[:name]).first
    else
      super
    end
  end
end
