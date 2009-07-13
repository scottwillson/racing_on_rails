# For now, this controller only redirects to ScheduleController.
# Longer-term, this controller should handle the schedule.
class EventsController < ApplicationController
  def index
    redirect_to schedule_path
  end
end
