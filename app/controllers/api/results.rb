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

    # Queries a collection of Result records from the database.
    # 
    # == Params
    # * page
    # * event_id (filters by races.event_id)
    # * person_id (filters by results.person_id)
    # 
    # == Returns
    # An array of 0 or more Race and grouped Result records, 10 per page, each
    # with the necessary joins for rendering a JSON or XML service response.
    # 
    # If no filtering parameter (i.e. event_id or person_id) is provided this
    # function will return an empty array.
    def results
      sql = []
      conditions = [""]

      # event_id
      if (params[:event_id])
        sql << "races.event_id = ?"
        conditions << params[:event_id]
      end

      # person_id
      if (params[:person_id])
        sql << "results.person_id = ?"
        conditions << params[:person_id]
      end

      if (sql)
        conditions[0] = sql.join(" AND ");
        Race.paginate(
          :page       => params[:page],
          :per_page   => 10,
          :conditions => conditions,
          :include    => { :results => [ :person, :category ] }
        )
      else
        []
      end
    end
  end
end
