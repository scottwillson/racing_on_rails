class Admin::ResultsController < ApplicationController
  before_filter :require_administrator
  layout "admin/application"

  in_place_edit_for :result, :age
  in_place_edit_for :result, :bar
  in_place_edit_for :result, :city
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
  
  def index
    @person = Person.find(params[:person_id])
    @results = Result.find_all_for(@person)
  end
  
  def find_person
    people = Person.find_all_by_name_like(params[:name], 20)
    ignore_id = params[:ignore_id]
    people.reject! {|r| r.id.to_s == ignore_id}
    if people.size == 1
      person = people.first
      results = Result.find_all_for(person)
      logger.debug("Found #{results.size} for #{person.name}")
      render(:partial => 'person', :locals => {:person => person, :results => results})
    else
      render :partial => 'people', :locals => {:people => people}
    end
  end
  
  def results
    person = Person.find(params[:id])
    results = Result.find_all_for(person)
    logger.debug("Found #{results.size} for #{person.name}")
    render(:partial => 'person', :locals => {:person => person, :results => results})
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
    original_result_owner = Person.find(result.person_id)
    person = Person.find(params[:person_id].to_s[/person_(.*)/, 1])
    result.person = person
    result.save!
    expire_cache
    render(:update) do |page|
      page.replace("person_#{person.id}", :partial => 'person', :locals => {:person => person, :results => person.results})
      page.replace("person_#{original_result_owner.id}", :partial => 'person', :locals => {:person => original_result_owner, :results => original_result_owner.results})
      page.visual_effect(:appear, "people", :duration => 0.6)
      page.hide('find_progress_icon')
    end
  end
end
