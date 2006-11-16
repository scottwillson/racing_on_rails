class Admin::PromotersController < ApplicationController

  model :promoter

  before_filter :login_required

  def index
    @promoters = Promoter.find(:all).sort_by{|p| p.name_or_contact_info}
  end

  def show
    @promoter = Promoter.find(params['id'])
    remember_event
  end
  
  def new
    @promoter = Promoter.new
    remember_event
    render(:template => 'admin/promoters/show')
  end

  def update
    begin
      remember_event
      if params['id'].blank?
        @promoter = Promoter.create(params['promoter'])
      else
        @promoter = Promoter.update(params['id'], params['promoter'])
      end
      if @promoter.errors.empty?
        if @event
          redirect_to(:action => :show, :id => @promoter.id, :event_id => @event.id)
        else
          redirect_to(:action => :show, :id => @promoter.id)
        end
      else
        render(:template => 'admin/promoters/show')
      end
    rescue Exception => e
      logger.error(e)
      flash['warn'] = e.message
      render(:template => 'admin/promoters/show')
    end
  end
  
  private
  
  def remember_event
    unless params['event_id'].blank?
      @event = Event.find(params['event_id'])
    end
  end
end
