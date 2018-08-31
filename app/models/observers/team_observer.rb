# frozen_string_literal: true

class TeamObserver < ActiveRecord::Observer
  def after_destroy(team)
    Result.where(team_id: team.id).update_all(team_id: nil, team_name: nil, team_member: false)
    true
  end

  def around_update(team)
    if team.member_changed?
      yield
      Result.where(team_id: team.id).update_all(team_member: team.member)
      Result.where(team_id: team.id, year: RacingAssociation.current.year).update_all(team_name: team.name)
    end

    true
  end
end
