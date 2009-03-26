class Admin::ResultsController < ApplicationController
  before_filter :check_administrator_role
  layout "admin/application"

  in_place_edit_for :result, :age
  in_place_edit_for :result, :bar
  in_place_edit_for :result, :category_name
  in_place_edit_for :result, :date_of_birth
  in_place_edit_for :result, :distance
  in_place_edit_for :result, :laps
  in_place_edit_for :result, :license
  in_place_edit_for :result, :name
  in_place_edit_for :result, :notes
  in_place_edit_for :result, :number
  in_place_edit_for :result, :place
  in_place_edit_for :result, :points
  in_place_edit_for :result, :points_bonus
  in_place_edit_for :result, :points_bonus_penalty
  in_place_edit_for :result, :points_from_place
  in_place_edit_for :result, :points_penalty
  in_place_edit_for :result, :points_total
  in_place_edit_for :result, :state
  in_place_edit_for :result, :team_name
  in_place_edit_for :result, :time_bonus_penalty_s
  in_place_edit_for :result, :time_gap_to_leader_s
  in_place_edit_for :result, :time_gap_to_winner_s
  in_place_edit_for :result, :time_s
  in_place_edit_for :result, :time_total_s
  
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
    original_result_owner = Racer.find(result.racer_id)
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
