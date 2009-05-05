class EventObserver < ActiveRecord::Observer
  def after_destroy(event)
    event.parent.update_date if event.parent && event.parent.respond_to?(:update_date)
  end

  def after_save(event)
    event.parent.update_date if event.parent && event.parent.respond_to?(:update_date)
    event.create_or_destroy_combined_results
    event.combined_results.calculate! if event.combined_results
  end
end
