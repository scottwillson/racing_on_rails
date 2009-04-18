class ResultObserver < ActiveRecord::Observer
  def after_destroy(result)
    result.event.create_or_destroy_combined_results if result.event.notification?
    result.event.combined_results.calculate! if result.event.combined_results
  end

  def after_save(result)
    result.event.create_or_destroy_combined_results if result.event.notification?
    result.event.combined_results.calculate! if result.event.combined_results
  end
end
