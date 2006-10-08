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
end
