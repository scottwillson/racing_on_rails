class Admin::AdminController < ApplicationController
  # Always show tabs
  def toggle_tabs
    @show_tabs = true
  end

  private
    # Force SSL for admin controllers. Overriding SSL gem.
    def ssl_required?
      RacingAssociation.current.ssl?
    end

    # Counter-intuitive. "True" means that we don't care if it's HTTPS or HTTP. Overriding SSLRequirement.
    def ssl_allowed?
      !RacingAssociation.current.ssl?
    end
end
