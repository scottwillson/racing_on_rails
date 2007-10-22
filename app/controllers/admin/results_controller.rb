class Admin::ResultsController < Admin::RecordEditor

  edits :result

  def create
    race = Race.find(params[:id])
    result = race.results.build(params[:result])
    result.save!
    flash[:notice] = "Saved new result #{result.place}"
    expire_cache
    redirect_to(:controller => "/admin/events", :action => :show, :id => race.standings.event.to_param, :race_id => race.to_param)
  end
  
  def edit
    @result = Result.find(params[:id])
  end
  
  # Editing the Racer or Team name will update the Result's current Racer's or Team's name, which 
  # may not be what you want. If you need to change the Racer or Team, and not just correct a misspelling,
  # Delete the Result and create a new one
  def update
    @result = Result.update(params[:result][:id], params[:result])
    
    if @result.errors.empty?
      flash[:notice] = "Updated result #{@result.place}"
      expire_cache
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
    result = Result.find(params[:id])
    race = result.race
    event = race.standings.event    
    notice = "Deleted result #{result.place}"
    
    result.destroy
    flash[:notice] = notice
    
    expire_cache
    redirect_to(:controller => "/admin/events", :action => :show, :id => event.to_param, :race_id => race.to_param)
  end
  
  def racer
  	@racer = Racer.find(params[:id])
  	@results = Result.find_all_for(@racer)
  end
  
  def find_racer
  	racers = Racer.find_all_by_name_like(params[:name], 20)
  	ignore_id = params[:ignore_id]
  	racers.reject! {|r| r.id.to_s == ignore_id}
  	if racers.size == 1
    	racer = racers.first
    	results = Result.find_all_for(racer)
    	logger.debug("Found #{results.size} for #{racer.name}")
      render(:partial => 'racer', :locals => {:racer => racer, :results => results})
	  else
    	render :partial => 'racers', :locals => {:racers => racers}
    end
  end
  
  def results
  	racer = Racer.find(params[:id])
  	results = Result.find_all_for(racer)
  	logger.debug("Found #{results.size} for #{racer.name}")
	  render(:partial => 'racer', :locals => {:racer => racer, :results => results})
  end
  
  def scores
    @result = Result.find(params[:id])
    @scores = @result.scores
    render(:update) {|page|
      page.insert_html(:after, "result_#{params[:id]}", :partial => 'score', :collection => @scores)
    }
  end
  
  def move_result
    result_id = params[:id].to_s
    result_id = result_id[/result_(.*)/, 1]
    result = Result.find(result_id)
    original_result_owner = Racer.find(result.racer.id)
    racer = Racer.find(params[:racer_id].to_s[/racer_(.*)/, 1])
    result.racer = racer
    result.save!
    expire_cache
    render(:update) do |page|
      page.replace("racer_#{racer.id}", :partial => 'racer', :locals => {:racer => racer, :results => racer.results})
      page.replace("racer_#{original_result_owner.id}", :partial => 'racer', :locals => {:racer => original_result_owner, :results => original_result_owner.results})
      page.visual_effect(:appear, "racers", :duration => 0.6)
      page.hide('find_progress_icon')
    end
  end
end
