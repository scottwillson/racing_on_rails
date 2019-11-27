# frozen_string_literal: true

class CalculatesController < ApplicationController
  before_action :require_administrator

  def create
    @calculation = Calculations::V3::Calculation.find(params[:calculation_id])
    @calculation.calculate!
    flash[:notice] = "Calculated #{@calculation.name}"
    redirect_to edit_calculation_path(@calculation)
  end
end
