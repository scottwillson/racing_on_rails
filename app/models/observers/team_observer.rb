class TeamObserver < ActiveRecord::Observer
  def after_destroy(team)
    Result.update_all [ "team_id=?, team_name=?", nil, nil ], [ "team_id=?", team.id ]
    true
  end

  def after_update(team)
    if team.name_changed?
      team.results.all.each do |result|
        if result.team_name != team.name(result.year)
          result.cache_attributes!
        end
      end
    end
    true
  end
end
