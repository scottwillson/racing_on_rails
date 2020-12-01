# frozen_string_literal: true

module Competitions
  class CompetitionsController < ApplicationController
    def show
      # Very explicit because we don't want to call something like 'eval' on a request parameter!
      case params[:type]
      when "rider_rankings"
        competition_class = RiderRankings
      when "cat4_womens_race_series"
        competition_class = Cat4WomensRaceSeries
      when "wsba_barr"
        competition_class = WsbaBarr
      when "wsba_masters_barr"
        competition_class = WsbaMastersBarr
      when "mbra_bar"
        competition_class = MbraBar
      when "oregon_tt_cup"
        competition_class = OregonTTCup
      when "oregon_womens_prestige_series"
        competition_class = OregonWomensPrestigeSeries
      else
        raise ActiveRecord::RecordNotFound, "No competition of type: #{params[:type]}"
      end

      @event = competition_class.year(@year).first || competition_class.new(date: Time.zone.local(@year))

      @races = Race.none

      if @event.new_record?
        @children = Event.none
        @single_day_event_children = Event.none
        @source_events = Event.none
      else
        @source_events = @event.source_events.include_results if @event.respond_to?(:source_events)

        @races = Race.where(event_id: @event.id).include_results
        @single_day_event_children = SingleDayEvent.where(parent_id: @event.id).include_child_results
        @children = Event.where(parent_id: @event.id).not_single_day_event.include_child_results
      end

      render "results/event"
    end
  end
end
