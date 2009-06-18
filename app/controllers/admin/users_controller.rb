# Manage race users
#
# User information shows up on the schedules
class Admin::UsersController < ApplicationController
  before_filter :require_administrator
  layout "admin/application"
  cache_sweeper :schedule_sweeper, :only => [:update]

  in_place_edit_for :user, :name
  in_place_edit_for :user, :email
  in_place_edit_for :user, :phone

  # List all Users
  # === Assigns
  # * users
  def index
    @users = User.find(:all).sort_by{|p| p.name_or_contact_info}
  end

  # === Params
  # * id
  # === Assigns
  # * user
  def edit
    @user = User.find(params['id'])
    remember_event
  end
  
  def new
    @user = User.new
    remember_event
    render(:action => :edit)
  end

  def create
    remember_event
    @user = User.create(params['user'])
    if @user.errors.empty?
      if @event
        redirect_to(edit_admin_event_user_path(@user, @event))
      else
        redirect_to(edit_admin_user_path(@user))
      end
    else
      render(:action => :edit)
    end
  end
  
  # Update new (no :id param) or existing User
  # No duplicate names
  def update
    remember_event
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      if @event
        redirect_to(edit_admin_event_user_path(@user, @event))
      else
        redirect_to(edit_admin_user_path(@user))
      end
    else
      render(:action => :edit)
    end
  end
  
  private
  
  def remember_event
    unless params['event_id'].blank?
      @event = Event.find(params['event_id'])
    end
  end
end
