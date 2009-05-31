class EventObserver < ActiveRecord::Observer
  def after_save(event)
    return true unless event.notification_enabled?
    CombinedTimeTrialResults.create_or_destroy_for!(event)
    true
  end
end
