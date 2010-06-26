class Api::EventController < ApplicationController
  def index
    events = Event.paginate(
      :include  => { :races => [ :category ] },
      :order    => "date DESC",
      :page     => params[:page],
      :per_page => 10
    )

    only = [:id, :parent_id, :name, :type, :discipline, :city, :cancelled, :beginner_friendly]
    includes = {
      :races => {
        :only => [:id, :distance, :city, :state, :laps, :field_size, :time, :finishers, :notes],
        :include => {
          :category => {
            :only => [:id, :name, :ages_begin, :ages_end, :friendly_param]
          }
        }
      }
    }

    respond_to do |format|
      format.xml { render :xml => events.to_xml(:only => only, :include => includes) }
      format.json { render :json => events.to_json(:only => only, :include => includes) }
    end
  end

  def results
    races = Race.paginate(
      :include  => { :results => [:person, :category] },
      :page     => params[:page],
      :per_page => 10
    )

    only = [:id, :distance, :city, :state, :laps, :field_size, :time, :finishers, :notes]
    includes = {
      :results => {
        :only => [:id, :age, :city, :date_of_birth, :license, :number, :place,
                  :place_in_category, :points, :points_from_place,
                  :points_bonus_penalty, :points_total, :state, :time,
                  :time_gap_to_leader, :time_gap_to_previous,
                  :time_gap_to_winner, :laps, :points_bonus, :points_penalty,
                  :preliminary, :gender, :category_class, :age_group,
                  :custom_attributes],
        :include => {
          :person => {
            :only => [:id, :first_name, :last_name, :license]
          },
          :category => {
            :only => [:id, :name, :ages_begin, :ages_end, :friendly_param]
          }
        }
      }
    }

    respond_to do |format|
      format.xml { render :xml => races.to_xml(:only => only, :include => includes) }
      format.json { render :json => races.to_json(:only => only, :include => includes) }
    end
  end
end
