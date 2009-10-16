class Admin::AdminController < ApplicationController
  def toggle_tabs
    @show_tabs = true
  end

  protected
    # Force SSL for admin controllers
    def ssl_required?
      ASSOCIATION.ssl?
    end
  
    def ssl_allowed?
      ASSOCIATION.ssl?
    end
end
