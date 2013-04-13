class OregonWomensPrestigeSeriesController < ApplicationController
  def show
    if params[:year] && params[:year].to_i > 0
      @year = params[:year].to_i
    else
      @year = Time.zone.today.year
    end
    
    @event = OregonWomensPrestigeSeries.find_for_year(@year) || OregonWomensPrestigeSeries.new
  end
end
