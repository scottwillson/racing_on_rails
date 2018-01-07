# frozen_string_literal: true

class FixResultTeamMember < ActiveRecord::Migration
  def change
    Result.transaction do
      count = 0
      Result.includes(:team).where.not(team_id: nil).find_each do |result|
        putc(".") if count % 1000 == 0
        result.cache_attributes! :non_event if result.team_member? != result.team.member?
        count += 1
      end
    end
    puts
  end
end
