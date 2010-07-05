# :stopdoc:
module Api
  module Results
    include Api::Base

    private

    def results_as_xml
      results.to_xml :only => race_fields, :include => race_includes(true)
    end

    def results_as_json
      results.to_json :only => race_fields, :include => race_includes(true)
    end

    def results
      Race.paginate(
        :page       => params[:page],
        :per_page   => 10,
        :conditions => { :event_id => params[:event_id] },
        :include    => { :results => [ :person, :category ] }
      )
    end
  end
end
