class Admin::AdminController < ApplicationController
  def toggle_tabs
    @show_tabs = true
  end

  protected

  # Force SSL for admin controllers
  def ssl_required?
    ASSOCIATION.ssl?
  end

  # Counter-intuitive. "True" means that we don't care if it's HTTPS or HTTP.
  def ssl_allowed?
    !ASSOCIATION.ssl?
  end
end
