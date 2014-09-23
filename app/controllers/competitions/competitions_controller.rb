module Competitions
  class CompetitionsController < ApplicationController
    def show
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
      elsif params[:type] == "oregon_tt_cup"
        competition_class = OregonTTCup
      else
        raise ActiveRecord::RecordNotFound.new("No competition of type: #{params[:type]}")
      end

      @event = competition_class.year(@year).first || competition_class.new(date: Time.zone.local(@year))

      @races = Race.none

      if @event.new_record?
        @children = Event.none
        @single_day_event_children = Event.none
        @source_events = Event.none
      else
        if @event.respond_to?(:source_events)
          @source_events = @event.source_events.include_results
        end

        @races = Race.where(event_id: @event.id).include_results
        @single_day_event_children = SingleDayEvent.where(parent_id: @event.id).include_child_results
        @children = Event.where(parent_id: @event.id).not_single_day_event.include_child_results
      end

      render "results/event"
    end
  end
end
