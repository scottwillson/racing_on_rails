# Just redirect to admin events index
class Admin::HomeController < Admin::AdminController
  def index
    redirect_to admin_events_path
  end
end