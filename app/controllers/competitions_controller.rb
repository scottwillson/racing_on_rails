class CompetitionsController < ApplicationController
  session :off
  caches_page :show

  # FIXME Replace hard-coded RiderRankings with eval
  def show
    @year = params['year'] || Date.today.year.to_s

    date = Date.new(@year.to_i, 1, 1)

    competition = RiderRankings.find(:first, :conditions => ['date = ?', date])
    
    if competition
      @standings = Standings.find(
        :first, 
        :conditions => ['event_id = ?', competition.id])

      @standings.races.reject! do |race|
        race.results.empty?
      end
    end
    @standings = @standings || Standings.new
  end
end
