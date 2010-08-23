# :stopdoc:
module Api
  module Events
    include Api::Base

    private

    def events_as_xml
      events.to_xml :only => event_fields, :include => event_includes
    end
    
    def events_as_json
      events.to_json :only => event_fields, :include => event_includes
    end

    def event_as_xml
      event.to_xml :only => event_fields, :include => event_includes
    end

    def event_as_json
      event.to_json :only => event_fields, :include => event_includes
    end

    # Queries a collection of Event records.
    # 
    # == Params
    # * page
    # 
    # == Returns
    # Returns an array of Event records in reverse-chronological order, 10 per
    # page, each with the necessary joins for rendering a JSON or XML service
    # response.
    def events
      Event.paginate(
        :include  => { :races => [ :category ] },
        :order    => "date DESC",
        :page     => params[:page],
        :per_page => 10
      )
    end

    # Retrieves a single Event record from the database.
    # 
    # == Params
    # * id
    # 
    # == Returns
    # An Event record, if found, with the necessary joins for rendering a JSON
    # or XML service response.
    def event
      Event.find(params[:id], :include => {
        :races => [ :category ]
      })
    end
  end
end