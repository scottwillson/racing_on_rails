class Api::EventController < ApplicationController
  def index
    events = Event.paginate(
      :include  => { :races => [ :category ] },
      :order    => "date DESC",
      :page     => params[:page],
      :per_page => 10
    )

    only = [:id, :parent_id, :name, :type, :discipline, :city, :cancelled, :beginner_friendly]
    includes = {
      :races => {
        :only => [:id, :distance, :city, :state, :laps, :field_size, :time, :finishers, :notes],
        :include => {
          :category => {
            :only => [:id, :name, :ages_begin, :ages_end, :friendly_param]
          }
        }
      }
    }

    respond_to do |format|
      format.xml { render :xml => events.to_xml(:only => only, :include => includes) }
      format.json { render :json => events.to_json(:only => only, :include => includes) }
    end
  end
end
