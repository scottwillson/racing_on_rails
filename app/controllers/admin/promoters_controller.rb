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
    render(:template => 'show')
  end

  def update
    if params['id'].blank?
      @promoter = Promoter.new(params['promoter'])
    else
      @promoter = Promoter.update(params['id'], params['promoter'])
    end
    remember_event
  end
  
  private
  
  def remember_event
    unless params['event_id'].blank?
      @event = Event.find(params['event_id'])
    end
  end
end
