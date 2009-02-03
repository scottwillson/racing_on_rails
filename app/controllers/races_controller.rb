class RacesController < ApplicationController

  # Show Races for a Category
  # === Params
  # * id: Category ID
  # === Assigns
  # * races
  # * category
  def index
    @category = Category.find(params[:category_id])
  end
end
