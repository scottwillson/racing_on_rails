class RacesController < ApplicationController
  model :race, :category

  # Show Races for a Category
  # === Params
  # * id: Category ID
  # === Assigns
  # * races
  # * category
  def category
    @category = Category.find(params[:id])
  end

end
