class Api::PersonController < ApplicationController
  def index
    people = []

    # name
    if params[:name]
      people = people + Person.find_all_by_name_like(params[:name])
    end

    # license
    if params[:license]
      people = people + Person.find_all_by_license(params[:license])
    end

    # order
    people.stable_sort_by(:first_name).stable_sort_by(:last_name)

    # paginage
    people = people.paginate(:page => params[:page])

    only = [:first_name, :last_name, :date_of_birth, :license, :gender]
    respond_to do |format|
      format.xml { render :xml => people.to_xml(:only => only) }
      format.json { render :json => people.to_json(:only => only) }
    end
  end
end
