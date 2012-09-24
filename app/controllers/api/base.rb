# Provides some shared code for the remote API.
module Api
  module Base

    private

    # Fields to use when rendering a Person object
    def person_fields
      [ :id, :first_name, :last_name, :date_of_birth, :license, :gender, :city ]
    end

    # Related objects to include when rendering a Person object
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

    # Fields to include when rendering an Event object
    def event_fields
      [ :id, :parent_id, :name, :type, :discipline, :city, :state, :cancelled, :beginner_friendly, :date ]
    end

    # Related objects to include when rendering an Event object
    def event_includes
      {
        :races => {
          :only    => race_fields,
          :include => race_includes
        }
      }
    end

    # Fields to use when rendering a Race object
    def race_fields
      [ :id, :distance, :city, :state, :laps, :field_size, :time, :finishers, :notes ]
    end

    # Related objects to include when rendering a Race object
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

    # Fields to use when rendering a Result object
    def result_fields
      [ :id, :age, :city, :date_of_birth, :license, :number, :place,
        :place_in_category, :points, :points_from_place,
        :points_bonus_penalty, :points_total, :state, :time,
        :time_gap_to_leader, :time_gap_to_previous, :time_gap_to_winner,
        :laps, :points_bonus, :points_penalty, :preliminary, :gender,
        :category_class, :age_group, :custom_attributes ]
    end

    # Related objects to include when rendering a Result object
    def result_includes
      {
        :person   => { :only => [ :id, :first_name, :last_name, :license ] },
        :category => { :only => category_fields }
      }
    end

    # Fields to use when rendering a Category object
    def category_fields
      [ :id, :name, :ages_begin, :ages_end, :friendly_param ]
    end
  end
end
