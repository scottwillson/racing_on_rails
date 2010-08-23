# Trigger changes to CombinedTimeTrialResults and update parent updated_at if child saved
class EventObserver < ActiveRecord::Observer
  def after_save(event)
    return true unless event.notification_enabled?
    event.parent.try :update_date
    CombinedTimeTrialResults.create_or_destroy_for!(event)
    true
  end

  def after_destroy(event)
    return true unless event.notification_enabled?
    event.parent.try :update_date
    true
  end
end
