class IronmanController < ApplicationController
  def index
    @ironman = Ironman.find_for_year(@year)
    if @ironman.nil?
      @ironman = Ironman.new(:date => Time.zone.local(@year), :races => [ Race.new ])
    end

    @years = @ironman.years(@year)
    
    request.session_options[:skip] = true
    if stale?(@ironman) && !@ironman.new_record?
      page = params[:page].to_i rescue 1
      page = 1 if page < 1
      @results = Result.where(:event_id => @ironman.id).includes(:person).order("cast(place as signed), person_id").paginate(:page => page, :per_page => 200)
    end
  end
end
