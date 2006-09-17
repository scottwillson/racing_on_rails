class Admin::EventsController < ApplicationController
  
  model :event

  def show
    @event = Event.find(params[:id])
    if params[:race_id]
      @race = Race.find(params[:race_id])
    elsif params[:standings_id]
      @standings = Standings.find(params[:standings_id])
    end

    @disciplines = [''] + Discipline.find_all.collect do |discipline|
      discipline.name
    end
    @disciplines.sort!
  end
  
  def new
    if params[:year].blank?
      date = Date.today
    else
      year = params[:year]
      date = Date.new(year.to_i)
    end
    @event = SingleDayEvent.new(:date => date)
  end
  
  def create
    event_params = params[:event].clone
    if event_params[:promoter].values.all? {|field| field.blank?}
      event_params[:promoter] = nil
    else
      if params[:same_promoter] == 'true'
        promoter = Promoter.find_by_info(event_params[:promoter][:name], event_params[:promoter][:email], event_params[:promoter][:phone])
        promoter = Promoter.create!(event_params[:promoter]) unless promoter
        update_promoter(promoter, event_params[:promoter])
        promoter.save! if promoter
        event_params[:promoter] = promoter
      else
        event_params[:promoter] = Promoter.create!(event_params[:promoter])
      end
    end
    @event = SingleDayEvent.new(event_params)
    if @event.create
      redirect_to(:action => :show, :id => @event.to_param)
    else
      flash[:warn] = @event.errors.full_messages
      "new"
    end
  end
  
  def update
    begin
      @event = Event.find(params[:id])
      original_event_attributes = @event.attributes.clone if @event.is_a?(MultiDayEvent)
      # TODO consolidate code
      event_params = params[:event].clone
      if event_params[:promoter].values.all? {|field| field.blank?}
        event_params[:promoter] = nil
      elsif params[:same_promoter] == 'true'
        promoter = Promoter.find_by_info(event_params[:promoter][:name], event_params[:promoter][:email], event_params[:promoter][:phone])
        promoter = Promoter.create!(event_params[:promoter]) unless promoter
        update_promoter(promoter, event_params[:promoter])
        promoter.save! if promoter
        event_params[:promoter] = promoter
      else
        event_params[:promoter] = Promoter.create!(event_params[:promoter])
      end
      @event = Event.update(params[:id], event_params)
    rescue Exception => e
      flash[:warn] = e
      return render(:action => :show)
    end
    
    if @event.errors.empty?
      @event.update_events(original_event_attributes) if @event.is_a?(MultiDayEvent)
      redirect_to(:action => :show, :id => params[:id])
    else
      render(:action => :show)
    end
  end
  
  def update_promoter(promoter, params)
     if promoter and (params[:name] != promoter.name or params[:email] != promoter.email or params[:phone] != promoter.phone)
       promoter.name = params[:name]
       promoter.email = params[:email]
       promoter.phone = params[:phone]
     end
   end
end
