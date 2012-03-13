# Allowed in-place editing added manually for each Result field. Dynamic Results columns will not work.
# All succcessful edit expire cache.
class Admin::ResultsController < Admin::AdminController
  before_filter :require_administrator
  layout "admin/application"
  
  # Move Results from one Person to another
  def index
    @person = Person.find(params[:person_id])
    @results = Result.find_all_for(@person)
  end
  
  # == Params
  # * name
  # * ignore_id: don't show this Person
  def find_person
    people = Person.find_all_by_name_like(params[:name], 20)
    ignore_id = params[:ignore_id]
    people.reject! {|r| r.id.to_s == ignore_id}
    if people.size == 1
      person = people.first
      results = Result.find_all_for(person)
      render(:partial => 'person', :locals => {:person => person, :results => results})
    else
      render :partial => 'people', :locals => {:people => people}
    end
  end
  
  def results
    person = Person.find(params[:person_id])
    results = Result.find_all_for(person)
    logger.debug("Found #{results.size} for #{person.name}")
    respond_to do |format|
      format.html { render(:partial => 'person', :locals => {:person => person, :results => results}) }
      format.js
    end
  end
  
  def scores
    @result = Result.find(params[:id])
    @scores = @result.scores
  end
  
  def move
    @result = Result.find(params[:result_id])
    @original_result_person = Person.find(@result.person_id)
    @person = Person.find(params[:person_id])
    @result.person = @person
    @result.save!
    expire_cache
  end

  def update_attribute
    respond_to do |format|
      format.js {
        @result = Result.find(params[:id])
        @result.send "#{params[:name]}=", params[:value]
        @result.save!
        expire_cache
        render :text => @result.send(params[:name]), :content_type => "text/html"
      }
    end
  end
end
