class Admin::AdminController < ApplicationController
  def toggle_tabs
    @show_tabs = true
  end

  protected
    # Force SSL for admin controllers
    def ssl_required?
      true
    end
  
    def ssl_allowed?
      true
    end
end
