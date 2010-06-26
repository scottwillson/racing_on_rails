module Api
  module Events

    private

    def events_as_xml
      events.to_xml :only => only, :include => includes
    end
    
    def events_as_json
      events.to_json :only => only, :include => includes
    end

    def events
      Event.paginate(
        :include  => { :races => [ :category ] },
        :order    => "date DESC",
        :page     => params[:page],
        :per_page => 10
      )
    end

    def only
      [ :id, :parent_id, :name, :type, :discipline, :city, :cancelled, :beginner_friendly ]
    end

    def includes
      {
        :races => {
          :only => [:id, :distance, :city, :state, :laps, :field_size, :time, :finishers, :notes],
          :include => {
            :category => {
              :only => [:id, :name, :ages_begin, :ages_end, :friendly_param]
            }
          }
        }
      }
    end
  end
end