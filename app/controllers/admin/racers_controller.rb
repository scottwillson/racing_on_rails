# Just redirect to People
class Admin::RacersController < ApplicationController
  before_filter :require_administrator
  
  def index
    redirect_to admin_people_path, :status => :moved_permanently
  end
end
