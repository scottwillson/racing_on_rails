# frozen_string_literal: true

module Competitions
  class IronmanController < ApplicationController
    def index
      @ironman = Ironman.find_for_year(@year)
      @ironman = Ironman.new(date: Time.zone.local(@year), races: [Race.new]) if @ironman.nil?

      @years = @ironman.years(@year)

      page = begin
               params[:page].to_i
             rescue StandardError
               1
             end
      page = 1 if page < 1
      @results = Result
                 .where(event_id: @ironman.id)
                 .includes(:person)
                 .order(Arel.sql("cast(place as signed), person_id"))
                 .paginate(page: page, per_page: 200)
    end
  end
end
