# Nicely-formatted version of parsed dates. Expects :date param. Echo param if date cannot be parsed.
class HumanDatesController < ApplicationController
  def show
    date = parser.parse(params[:date].try(:gsub, ".json", ""))

    if date
      render :json => date.to_s(:long_with_week_day).to_json
    else
      render :json => params[:date].to_json
    end
  end
  
  protected
  
  def parser
    HumanDate::Parser.new
  end
end
