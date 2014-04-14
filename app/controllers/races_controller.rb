class RacesController < ApplicationController

  # Show Races for a Category
  # === Params
  # * id: Category ID
  # === Assigns
  # * races
  # * category
  def index
    if params[:event_id]
      @event = Event.includes(:races).find(params[:event_id])
      redirect_to event_results_path(@event)
    else
      @category = Category.includes(races: :event).find(params[:category_id])
    end
  end

  def show
    @race = Race.find(params[:id])
    redirect_to event_results_path(@race.event)
  end
end
