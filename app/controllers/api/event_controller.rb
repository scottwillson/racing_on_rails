class Api::EventController < ApplicationController
  def index
    events = Event.all
    respond_to do |format|
      format.xml {
        render :xml => events.to_xml(
          :methods => [ :start_date, :end_date ],
          :include => [ :races ]
        )
      }
    end
  end
end
