class Api::EventController < ApplicationController
  def index
    events = Event.paginate(:order => :date, :page => params[:page])

    only = [:id, :parent_id, :name, :type, :discipline, :city, :cancelled, :beginner_friendly]
    for_include = {
      :races => {
        :only => [:id, :city, :distance, :state, :laps, :field_size, :time, :finishers, :notes],
        :include => {
          :category => {
            :only => [:id, :name, :ages_begin, :ages_end, :friendly_param]
          }
        }
      }
    }

    respond_to do |format|
      format.xml { render :xml => events.to_xml(:only => only, :include => for_include) }
      format.json { render :json => events.to_json(:only => only, :include => for_include) }
    end
  end
end
