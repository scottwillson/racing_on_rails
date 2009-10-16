class Admin::FirstAidProvidersController < Admin::AdminController
  before_filter :require_administrator
  helper :table
  layout "admin/application"

  def index
    @year = Date.today.year
    
    @past_events = params[:past_events] || false
    if @past_events
      conditions = ['date >= ?', Date.today.beginning_of_year]
    else
      conditions = ['date >= CURDATE()']
    end
    
    if params[:sort_by].present?
      @sort_by = params[:sort_by]
    else
      @sort_by = "date"
    end
    
    @events = SingleDayEvent.find(:all, :conditions => conditions)
    
    respond_to do |format|
      format.html
      format.text { email }
    end
  end

  def email
    rows = @events.collect do |event|
      [event.first_aid_provider, event.date.strftime("%a %m/%d") , event.name, event.city_state]
    end
    grid = Grid.new(rows)
    grid.truncate_rows
    grid.calculate_padding
    
    headers['Content-Type'] = 'text/plain'

    render :text => grid.to_s(false)
  end
end