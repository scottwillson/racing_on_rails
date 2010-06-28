module Api
  module Base

    private

    def person_fields
      [ :id, :first_name, :last_name, :date_of_birth, :license, :gender ]
    end
  
    def person_includes
      {
        :aliases      => { :only => [ :alias, :name ] },
        :team         => { :only => [ :name, :city, :state, :website ] },
        :race_numbers => {
          :only    => [ :value, :year ],
          :include => {
            :discipline => { :only => :name }
          }
        }
      }
    end

    def event_fields
      [ :id, :parent_id, :name, :type, :discipline, :city, :cancelled, :beginner_friendly ]
    end

    def event_includes
      {
        :races => {
          :only    => race_fields,
          :include => race_includes
        }
      }
    end

    def race_fields
      [ :id, :distance, :city, :state, :laps, :field_size, :time, :finishers, :notes ]
    end

    def race_includes(with_results=false)
      includes = {
        :category => {
          :only => category_fields
        }
      }

      if with_results
        includes[ :results ] = {
          :only    => result_fields,
          :include => result_includes
        }
      end

      includes
    end

    def result_fields
      [ :id, :age, :city, :date_of_birth, :license, :number, :place,
        :place_in_category, :points, :points_from_place,
        :points_bonus_penalty, :points_total, :state, :time,
        :time_gap_to_leader, :time_gap_to_previous, :time_gap_to_winner,
        :laps, :points_bonus, :points_penalty, :preliminary, :gender,
        :category_class, :age_group, :custom_attributes ]
    end

    def result_includes
      {
        :person   => { :only => [ :id, :first_name, :last_name, :license ] },
        :category => { :only => category_fields }
      }
    end

    def category_fields
      [ :id, :name, :ages_begin, :ages_end, :friendly_param ]
    end
  end
end
