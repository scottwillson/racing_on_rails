class IronmanController < ApplicationController
  session :off

  def index
    @year = params['year'] || Date.today.year.to_s
    date = Date.new(@year.to_i, 1, 1)
    ironman_competition = Ironman.find(:first, :conditions => ['date = ?', date])
    if ironman_competition
      @ironman = ironman_competition.standings.first
      race = ironman_competition.standings.first.races.first
      @results = Result.paginate( :conditions => ['race_id = ?', race.id],
                                  :include => [:racer],
                                  :order => 'cast(place as signed)',
                                  :limit  =>  200,
                                  :page =>  params['page']
                                )
    else
      @ironman = nil
    end
    @years = Ironman.years
  end
end
