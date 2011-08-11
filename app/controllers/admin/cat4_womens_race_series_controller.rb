# Add Result to Cat4WomensRaceSeries. The series counts races outside of the association, so they some are added manually.
class Admin::Cat4WomensRaceSeriesController < Admin::AdminController

  before_filter :require_administrator
  layout 'admin/application'
  
  def new_result
    @result = Result.new(params[:result])
  end
  
  # Create Result and create SingleDayEvent and Race if there is no existing Event with same name and date
  def create_result
    event_for_find = SingleDayEvent.new(params[:event])
    @event = Event.first(:conditions => { :name => event_for_find.name, :date => event_for_find.date })
    if @event.nil?
      @event = SingleDayEvent.new(params[:event])
      @event.save!
      unless params[:event][:sanctioned_by]
        @event.sanctioned_by = nil 
        @event.save!
      end
    end

    cat_4_women = Category.find_or_create_by_name("Women Cat 4")
    @race = @event.races.detect do |r|
      r.category == cat_4_women || cat_4_women.descendants.include?(r.category)
    end
    if @race.nil?
      @race = @event.races.create!(:category => cat_4_women)
    end
    
    @result = @race.results.new(params[:result])
    @result.validate_person_name
    if @result.errors.empty?
      @result.save!
      flash[:notice] = "Created result for #{@result.name} in #{@event.name}"
      redirect_to(:action => "new_result", :result => { 
                                                        :first_name => params[:result][:first_name],
                                                        :last_name => params[:result][:last_name],
                                                        :team_name => params[:result][:team_name],
                                                         })
    else
      render :new_result
    end
  end
end
