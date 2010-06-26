class Api::PersonController < ApplicationController
  def index
    sql = []
    conditions = [""]

    # name
    if params[:name]
      name = "%#{params[:name].strip}%"
      sql << "(CONCAT_WS(' ', first_name, last_name) LIKE ? OR aliases.name LIKE ?)"
      conditions << name << name
    end

    # license
    if params[:license]
      sql << "(license = ?)"
      conditions << params[:license]
    end

    if sql
      conditions[0] = sql.join(" AND ")
      people = Person.paginate(
        :page       => params[:page],
        :per_page   => 10,
        :conditions => conditions,
        :include    => {
          :aliases      => [],
          :team         => [],
          :race_numbers => [:discipline]
        }
      )
    else
      people = []
    end

    only = [:id, :first_name, :last_name, :date_of_birth, :license, :gender]
    includes = {
      :aliases      => { :only => [:alias, :name] },
      :team         => { :only => [:name, :city, :state, :website] },
      :race_numbers => {
        :only    => [:value, :year],
        :include => {
          :discipline => { :only => :name }
        }
      }
    }

    respond_to do |format|
      format.xml { render :xml => people.to_xml(:only => only, :include => includes) }
      format.json { render :json => people.to_json(:only => only, :include => includes) }
    end
  end
end
