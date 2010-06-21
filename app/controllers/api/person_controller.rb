class Api::PersonController < ApplicationController
  def index
    people = []
    select = [:first_name, :last_name, :date_of_birth, :license, :gender]

    # name
    if params[:name]
      people = people + Person.find_all_by_name_like(params[:name], :select => select.join(','))
    end

    # license
    if params[:license]
      people = people + Person.find_all_by_license(params[:license], :select => select.join(','))
    end

    # order
    people.stable_sort_by(:first_name).stable_sort_by(:last_name)

    # limit
    people = people[0, 5]

    respond_to do |format|
      format.xml { render :xml => people.to_xml }
      format.json { render :json => people.to_json }
    end
  end
end
