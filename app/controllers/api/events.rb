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

    def events
      Event.paginate(
        :include  => { :races => [ :category ] },
        :order    => "date DESC",
        :page     => params[:page],
        :per_page => 10
      )
    end
  end
end