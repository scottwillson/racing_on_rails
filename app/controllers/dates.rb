module Dates
  extend ActiveSupport::Concern

  included do
    before_filter :assign_year, :assign_today
  end

  def assign_year
    if params[:year] && params[:year][/^\d\d\d\d$/]
      @year = params[:year].to_i
    end

    if @year.nil? || @year < 1900 || @year > 2100
      @year = RacingAssociation.current.effective_year
    end
  end

  def assign_today
    @today = Time.zone.today
  end
end
