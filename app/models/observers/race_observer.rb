class RaceObserver < ActiveRecord::Observer
  def after_update(race)
    Result.update_all [ "race_name = ?, race_full_name = ?", race.name, race.full_name ], [ "race_id = ?", race.id]    
  end
end
