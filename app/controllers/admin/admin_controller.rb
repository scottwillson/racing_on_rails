class Admin::AdminController < ApplicationController
  # Always show tabs
  def toggle_tabs
    @show_tabs = true
  end

  private
    # Force SSL for admin controllers. Overriding SSL gem.
    def ssl_required?
      ASSOCIATION.ssl?
    end

    # Counter-intuitive. "True" means that we don't care if it's HTTPS or HTTP. Overriding SSLRequirement em.
    def ssl_allowed?
      !ASSOCIATION.ssl?
    end
end
