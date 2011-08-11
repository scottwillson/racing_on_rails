class IronmanController < ApplicationController
  def index
    @year = params['year'] || Date.today.year.to_s
    date = Date.new(@year.to_i, 1, 1)
    @ironman = Ironman.first(:conditions => ['date = ?', date])
    if @ironman && !@ironman.races.empty?
      @results = Result.paginate( :conditions => ['race_id = ?', @ironman.races.first.id],
                                  :include => [:person],
                                  :order => 'cast(place as signed)',
                                  :limit  =>  200,
                                  :page =>  params['page']
                                )
    end
    @years = Ironman.years
  end
end
