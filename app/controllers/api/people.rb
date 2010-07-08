# :stopdoc:
module Api
  module People
    include Api::Base
    
    private
    
    def people_as_xml
      people.to_xml :only => person_fields, :include => person_includes
    end
    
    def people_as_json
      people.to_json :only => person_fields, :include => person_includes
    end

    def person_as_xml
      person.to_xml :only => person_fields, :include => person_includes
    end

    def person_as_json
      person.to_json :only => person_fields, :include => person_includes
    end

    def people
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
        Person.paginate(
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
        []
      end
    end  

    def person
      Person.find(params[:id], :include => {
        :aliases      => [],
        :team         => [],
        :race_numbers => [:discipline]
      })
    end
  end
end