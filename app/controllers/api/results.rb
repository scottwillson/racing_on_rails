module Api
  module Results

    include Api::Base

    private

    def results_as_xml
      results.to_xml :only => event_fields, :include => event_includes(true)
    end

    def results_as_json
      results.to_json :only => event_fields, :include => event_includes(true)
    end

    def results
      Race.paginate(
        :conditions => { :event_id => params[:event_id] },
        :include    => { :results => [ :person, :category ] },
        :page       => params[:page],
        :per_page   => 10
      )
    end
  end
end
