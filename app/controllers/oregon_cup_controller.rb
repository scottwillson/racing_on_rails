class OregonCupController < ApplicationController
  def index
    if params[:year] && params[:year].to_i > 0
      @year = params[:year].to_i
    else
      @year = Time.zone.today.year
    end
    
    @oregon_cup = OregonCup.find_for_year(@year) || OregonCup.new
  end
end
