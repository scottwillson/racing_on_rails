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
      logger.debug("Found #{results.size} for #{person.name}")
      render(:partial => 'person', :locals => {:person => person, :results => results})
    else
      render :partial => 'people', :locals => {:people => people}
    end
  end
  
  def results
    person = Person.find(params[:person_id])
    results = Result.find_all_for(person)
    logger.debug("Found #{results.size} for #{person.name}")
    render(:partial => 'person', :locals => {:person => person, :results => results})
  end
  
  def scores
    @result = Result.find(params[:id])
    @scores = @result.scores
    render :update do |page|
      page.insert_html :after, "result_#{params[:id]}_row", :partial => 'score', :collection => @scores
    end
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
    render :update do |page|
      page.replace "person_#{person.id}", :partial => "person", :locals => { :person => person, :results => person.results }
      page.replace "person_#{original_result_owner.id}", :partial => "person", :locals => { :person => original_result_owner, :results => original_result_owner.results }
      page[:people].css "opacity", 1
      page.hide 'find_progress_icon'
    end
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
