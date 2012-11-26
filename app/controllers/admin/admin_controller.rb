class Admin::AdminController < ApplicationController
  force_https
  before_filter :require_administrator
  
  # Always show tabs
  def toggle_tabs
    @show_tabs = true
  end
end
