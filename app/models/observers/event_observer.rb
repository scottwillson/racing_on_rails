# Trigger changes to CombinedTimeTrialResults and update parent updated_at if child saved
class EventObserver < ActiveRecord::Observer
  def after_save(event)
    Result.update_all [ "event_full_name = ?, event_date_range_s = ?, event_end_date = ?, date = ?", 
                        event.full_name, event.date_range_s(:long), event.end_date, event.date ], 
                      [ "event_id = ?", event.id]
    return true unless event.notification_enabled?
    event.parent.try :update_date
    CombinedTimeTrialResults.create_or_destroy_for! event
    true
  end

  def after_destroy(event)
    return true unless event.notification_enabled?
    event.parent.try :update_date
    true
  end
end
