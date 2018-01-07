# frozen_string_literal: true

module Dates
  extend ActiveSupport::Concern

  included do
    before_action :assign_year, :assign_today
  end

  def assign_year
    @year = params[:year].to_i if params[:year] && params[:year][/^\d\d\d\d$/]

    @year = RacingAssociation.current.effective_year if @year.nil? || @year < 1900 || @year > 2100
  end

  def assign_today
    @today = Time.zone.today
  end
end
