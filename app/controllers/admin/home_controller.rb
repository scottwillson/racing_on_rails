module Admin
  # Just redirect to admin events index
  class HomeController < Admin::AdminController
    def index
      flash.keep
      redirect_to admin_events_path
    end
  end
end
