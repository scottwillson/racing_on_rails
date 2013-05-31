# Work assignments for Event. First aid provider and chief official.
# Officials can view, but not edit, this page.
class Admin::FirstAidProvidersController < Admin::AdminController
  skip_filter :require_administrator
  before_filter :require_administrator_or_official
  helper :table
  layout "admin/application"

  def index
    @year = RacingAssociation.current.effective_year
    
    @past_events = (params[:past_events] == "true") || false
    if @past_events
      conditions = [ 'date >= ?', RacingAssociation.current.effective_today ]
    else
      conditions = [ 'date >= CURDATE()' ]
    end
    
    if params[:sort_by].present?
      @sort_by = params[:sort_by]
    else
      @sort_by = "date"
    end
    
    @events = SingleDayEvent.all( :conditions => conditions)
    
    respond_to do |format|
      format.html
      format.text { email }
    end
  end

  # Formatted for "who would like to work this race email"
  def email
    rows = @events.collect do |event|
      [event.first_aid_provider, event.date.strftime("%a %-m/%-d") , event.name, event.city_state]
    end
    grid = RacingOnRails::Grid::Grid.new(rows)
    grid.truncate_rows
    grid.calculate_padding
    
    headers['Content-Type'] = 'text/plain'

    render :text => grid.to_s(false)
  end
end