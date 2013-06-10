module Admin
  # Allowed in-place editing added manually for each Result field. Dynamic Results columns will not work.
  # All succcessful edit expire cache.
  class ResultsController < Admin::AdminController
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
        render :partial => "person", :locals => { :person => person, :results => results }
      else
        render :partial => "people", :locals => { :people => people }
      end
    end
  
    def results
      person = Person.find(params[:person_id])
      results = Result.find_all_for(person)
      logger.debug("Found #{results.size} for #{person.name}")
      respond_to do |format|
        format.html { render(:partial => "person", :locals => { :person => person, :results => results }) }
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
        format.js do
          @result = Result.find(params[:id])
          @result.send "#{params[:name]}=", params[:value]
          @result.save!
          expire_cache
        
          if @result.respond_to?("#{params[:name]}_s")
            text = @result.send("#{params[:name]}_s")
          else
            text = @result.send(params[:name])
          end
        
          render :text => text, :content_type => "text/html"
        end
      end
    end

    # Insert new Result
    # === Params
    # * race_id
    # * before_result_id
    # === Flash
    # * notice
    def create
      @race = Race.find(params[:race_id])
      @result = @race.create_result_before(params[:before_result_id])
      expire_cache
    end

    # Permanently destroy Result
    # === Params
    # * id
    # === Flash
    # * notice
    def destroy
      @result = Result.includes(:race).find(params[:id])
      @race = @result.race
      @race.destroy_result @result
      @race.results true
    end

    protected

    def assign_current_admin_tab
      @current_admin_tab = "People"
    end
  end
end
