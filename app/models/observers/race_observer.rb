class RaceObserver < ActiveRecord::Observer
  def after_update(race)
    Result.where(:race_id => race.id).update_all(:race_name => race.name, :race_full_name => race.full_name)
  end
end
