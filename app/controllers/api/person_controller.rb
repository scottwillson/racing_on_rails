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
          :only    => [:first_name, :last_name, :date_of_birth, :license, :gender],
          :include => [:team]
        )
      }
    end
  end
end
