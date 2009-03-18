# Manage race promoters
#
# Promoter information shows up on the schedules
class Admin::PromotersController < ApplicationController
  before_filter :check_administrator_role
  layout "admin/application"
  cache_sweeper :schedule_sweeper, :only => [:update]

  in_place_edit_for :promoter, :name
  in_place_edit_for :promoter, :email
  in_place_edit_for :promoter, :phone

  # List all Promoters
  # === Assigns
  # * promoters
  def index
    @promoters = Promoter.find(:all).sort_by{|p| p.name_or_contact_info}
  end

  # === Params
  # * id
  # === Assigns
  # * promoter
  def edit
    @promoter = Promoter.find(params['id'])
    remember_event
  end
  
  def new
    @promoter = Promoter.new
    remember_event
    render(:action => :edit)
  end

  def create
    remember_event
    @promoter = Promoter.create(params['promoter'])
    if @promoter.errors.empty?
      if @event
        redirect_to(edit_admin_event_promoter_path(@promoter, @event))
      else
        redirect_to(edit_admin_promoter_path(@promoter))
      end
    else
      render(:action => :edit)
    end
  end
  
  # Update new (no :id param) or existing Promoter
  # No duplicate names
  def update
    remember_event
    @promoter = Promoter.find(params[:id])
    if @promoter.update_attributes(params[:promoter])
      logger.debug("Updated OK")
      logger.debug("@event: #{@event}")
      if @event
        redirect_to(edit_admin_event_promoter_path(@promoter, @event))
      else
        redirect_to(edit_admin_promoter_path(@promoter))
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
