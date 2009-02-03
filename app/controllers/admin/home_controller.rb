class Admin::HomeController < ApplicationController
  def index
    redirect_to admin_events_path
  end
end