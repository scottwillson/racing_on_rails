module Api
  module People 
    
    private
    
    def people_as_xml
      people.to_xml :only => only, :include => includes
    end
    
    def people_as_json
      people.to_json :only => only, :include => includes
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
  
    def only
      [ :id, :first_name, :last_name, :date_of_birth, :license, :gender ]
    end
  
    def includes
      {
        :aliases      => { :only => [:alias, :name] },
        :team         => { :only => [:name, :city, :state, :website] },
        :race_numbers => {
          :only    => [:value, :year],
          :include => {
            :discipline => { :only => :name }
          }
        }
      }
    end
  end
end