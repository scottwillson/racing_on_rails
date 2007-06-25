class Admin::ResultsController < Admin::RecordEditor

  model :result
  edits :result

  def create
    race = Race.find(@params[:id])
    result = race.results.build(@params[:result])
    result.save!
    flash[:notice] = "Saved new result #{result.place}"
    redirect_to(:controller => "/admin/events", :action => :show, :id => race.standings.event.to_param, :race_id => race.to_param)
  end
  
  def edit
    @result = Result.find(@params[:id])
  end
  
  # Editing the Racer or Team name will update the Result's current Racer's or Team's name, which 
  # may not be what you want. If you need to change the Racer or Team, and not just correct a misspelling,
  # Delete the Result and create a new one
  def update
    @result = Result.update(@params[:result][:id], @params[:result])
    
    if @result.errors.empty?
      flash[:notice] = "Updated result #{@result.place}"
      redirect_to(
        :controller => "/admin/events", 
        :action => :show, 
        :id => @result.race.standings.event.to_param, 
        :race_id => @result.race.to_param)
    else
      'admin/results/edit'
    end
  end
  
  def destroy
    # Get data _before_ delete
    result = Result.find(@params[:id])
    race = result.race
    event = race.standings.event    
    notice = "Deleted result #{result.place}"
    
    result.destroy
    flash[:notice] = notice
    
    redirect_to(:controller => "/admin/events", :action => :show, :id => event.to_param, :race_id => race.to_param)
  end
  
  def racer
  	@racer = Racer.find(params[:id])
  	raise "Could not find racer with id #{params[:id]}" if @racer.nil?
    # @results = Result.find(
    #   :all,
    #       :include => [:team, :racer, :scores, :category, {:race => {:standings => :event}, :race => :category}],
    #       :conditions => ['racers.id = ?', params[:id]]
    # )
  	@results = @racer.event_results
    @racers = []
  end
  
  def find_racer
  	@racers = Racer.find_by_name_like(params[:name], 20)
  	ignore_id = params[:left_racer_id]
  	@racers.reject! {|r| r.id.to_s == ignore_id}
  	@name = params[:name]
  	if @racers.size == 1
  	  redirect_to(:action => :select_racer, :name => @name, :id => @racers.first.id)
	  else
    	render :partial => 'find_racer', :locals => {:left_racer_id => ignore_id}
    end
  end
  
  def select_racer
  	@racer = Racer.find(params[:id])
  	@name = params[:name]
  	@results = @racer.event_results
  	render :partial => 'results'
  end
  
  def move_result
    result_id = params[:id].to_s
    result_id = result_id[/result_(.*)/, 1]
    result = Result.find(result_id)
    racer = Racer.find(params[:racer_id])
    result.racer = racer
    result.save!
  end
end
