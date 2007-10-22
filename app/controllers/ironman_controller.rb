class IronmanController < ApplicationController
  session :off

  def index
    @year = params['year'] || Date.today.year.to_s
    date = Date.new(@year.to_i, 1, 1)
    ironman_competition = Ironman.find(:first, :conditions => ['date = ?', date])
    if ironman_competition
      @ironman = ironman_competition.standings.first
      race = ironman_competition.standings.first.races.first
      @pages = Paginator.new self, race.results.count, 200, params['page']
      @results = Result.find(:all, 
                            :conditions => ['race_id = ?', race.id],
                            :include => [:racer],
                            :order => 'cast(place as signed)',
                            :limit  =>  @pages.items_per_page,
                            :offset =>  @pages.current.offset
                )
    else
      @ironman = nil
    end
    @years = Ironman.years
  end
end
