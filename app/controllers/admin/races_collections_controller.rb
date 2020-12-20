# frozen_string_literal: true

module Admin
  class RacesCollectionsController < Admin::AdminController
    before_action :assign_event
    before_action :require_administrator_or_promoter

    def create
      @event.add_races_from_previous_year
      respond_to do |format|
        format.js { render :show }
      end
    end

    def edit
      @races_collection = RacesCollection.new(@event)
      respond_to do |format|
        format.js
      end
    end

    def show
      @races_collection = RacesCollection.new(@event)
      assign_previous
      respond_to do |format|
        format.js
      end
    end

    def update
      @races_collection = RacesCollection.new(@event)
      @races_collection.update(races_collection_params)
      @event.races.reload
      assign_previous
      respond_to do |format|
        format.js { render :show }
      end
    end

    private

    def assign_event
      @event = Event.includes(races: :category).find(params[:event_id])
    end

    def assign_previous
      @previous = nil

      @previous = @event.previous_year if @event.races.empty?
    end

    def races_collection_params
      params.require(:races_collection).permit(:text)
    end
  end
end
