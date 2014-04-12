module Admin
  # Work assignments for Event. First aid provider and chief official.
  # Officials can view, but not edit, this page.
  class FirstAidProvidersController < Admin::AdminController
    skip_filter :require_administrator
    before_filter :require_administrator_or_official
    helper :table

    def index
      @past_events = (params[:past_events] == "true") || false
      if @past_events
        @events = SingleDayEvent.current_year
      else
        @events = SingleDayEvent.today_and_future
      end
      
      if params[:sort_by].present?
        @sort_by = params[:sort_by]
      else
        @sort_by = "date"
      end
    
      @events = @events.where(:practice => false).where(:cancelled => false).where(:postponed => false)
    
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

      render :plain => grid.to_s(false)
    end

    protected

    def assign_current_admin_tab
      @current_admin_tab = "First Aid"
    end
  end
end
