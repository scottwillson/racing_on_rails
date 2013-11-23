class CompetitionsController < ApplicationController
  caches_page :show
  
  def show
    date = Date.new(@year.to_i, 1, 1)

    # Very explicit because we don't want to call something like 'eval' on a request parameter!
    if params[:type] == "rider_rankings"
      competition_class = RiderRankings
    elsif params[:type] == "cat4_womens_race_series"
      competition_class = Cat4WomensRaceSeries
    elsif params[:type] == "wsba_barr"
      competition_class = WsbaBarr
    elsif params[:type] == "wsba_masters_barr"
      competition_class = WsbaMastersBarr
    elsif params[:type] == "mbra_bar"
      competition_class = MbraBar
    else
      raise ActiveRecord::RecordNotFound.new("No competition of type: #{params[:type]}")
    end

    @event = competition_class.year(@year).first || competition_class.new(:date => Time.zone.local(@year))
  end
end
