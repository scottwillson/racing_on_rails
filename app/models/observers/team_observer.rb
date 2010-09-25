class TeamObserver < ActiveRecord::Observer
  def after_destroy(team)
    Result.update_all [ "team_id=?, team_name=?", nil, nil ], [ "team_id=?", team.id ]
    true
  end

  def after_update(team)
    if team.name_changed?
      team.results.all.each do |result|
        if result.team_name != team.name(result.year)
          result.logger.debug "TeamObserver#after_create set result name #{result[:team_name]} to #{team.name(result.year)}"
          result.event.disable_notification!
          result.cache_attributes
          result.save!
          result.logger.debug "TeamObserver#after_create #{result[:team_name]}"
          result.event.enable_notification!
        end
      end
    end
    true
  end
end
