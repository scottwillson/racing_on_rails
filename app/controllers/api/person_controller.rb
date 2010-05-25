class Api::PersonController < ApplicationController
  def index
    conditions = { }
    if params[:license]
      conditions[:license] = params[:license]
    end
    people = Person.all(:conditions => conditions)
    respond_to do |format|
      format.xml {
        render :xml => people.to_xml(
          :include => [ :aliases, :events, :race_numbers, :results, :team ]
        )
      }
    end
  end
end
