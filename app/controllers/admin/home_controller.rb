# Just redirect to admin events index
class Admin::HomeController < Admin::AdminController
  def index
    flash.keep
    redirect_to admin_events_path
  end
end