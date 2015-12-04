module Admin
  class RacesCollectionsController < Admin::AdminController
    before_action :assign_event
    before_action :require_administrator_or_promoter

    def edit
      @races_collection = RacesCollection.new(@event)
      respond_to do |format|
        format.js
      end
    end

    def show
      @races_collection = RacesCollection.new(@event)
      respond_to do |format|
        format.js
      end
    end

    def update
      @races_collection = RacesCollection.new(@event)
      @races_collection.update(races_collection_params)
      @event.races true
      respond_to do |format|
        format.js { render :show }
      end
    end

    private

    def assign_event
      @event = Event.includes(races: :category).find(params[:event_id])
    end

    def races_collection_params
      params_without_mobile.require(:races_collection).permit(:text)
    end
  end
end
