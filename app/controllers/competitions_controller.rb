class CompetitionsController < ApplicationController
  session :off
  caches_page :show

  def show
    @year = params['year'] || Date.today.year.to_s
    date = Date.new(@year.to_i, 1, 1)

    # Very explicit because we don't want to call something like 'eval' on a request parameter!
    if params[:type] == "rider_rankings"
      competition_class = RiderRankings
    elsif params[:type] == "cat4_womens_race_series"
      competition_class = Cat4WomensRaceSeries
    else
      return render(:file => "#{RAILS_ROOT}/public/404.html", :status => 404)
    end
    competition = competition_class.find(:first, :conditions => ['date = ?', date])
    
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
