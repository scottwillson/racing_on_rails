class IronmanController < ApplicationController
  def index
    @ironman = Ironman.find_for_year(@year)
    if @ironman
      page = params['page'].to_i rescue 1
      page = 1 if page < 1
    
      @results = Result.where(:event_id => @ironman.id).includes(:person).order("cast(place as signed)").limit(200)
    else
      @ironman = Ironman.new(:date => Time.zone.local(@year), :races => [ Race.new ])
      @results = ActiveRecord::NullRelation
    end

    @results = @results.page(page)
    @years = @ironman.years(@year)
  end
end
