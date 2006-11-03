class ObraController < ApplicationController

  model :event, :upcoming_events
  layout nil
  
  def upcoming_events
    if params['date'].blank?
      @date = Date.today
    else
      @date = Date.new(params['date']['year'].to_i, params['date']['month'].to_i, params['date']['day'].to_i)
    end
    if params['weeks'].blank?
      @weeks = 2
    else
      @weeks = params['weeks']
    end
    @upcoming_events = UpcomingEvents.new(@date, @weeks)
    render :partial => 'upcoming_events'
  end
end
