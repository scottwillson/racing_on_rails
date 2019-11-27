# frozen_string_literal: true

class CalculationsController < ApplicationController
  before_action :require_administrator, only: :edit

  def edit
    @calculation = Calculations::V3::Calculation.find(params[:id])
  end

  def index
    @calculations = Calculations::V3::Calculation.all
  end

  def show
    @calculation = Calculations::V3::Calculation.find(params[:id])
  end

  def update
    @calculation = Calculations::V3::Calculation.find(params[:id])
    if @calculation.update(calculation_params)
      flash[:notice] = "Updated #{@calculation.name}"
      redirect_to edit_calculation_path(@calculation)
    else
      render :edit
    end
  end

  private

  def calculation_params
    params.require(:calculation).permit(
      :association_sanctioned_only,
      :double_points_for_last_event,
      :group_by,
      :key,
      :maximum_events,
      :members_only,
      :minimum_events,
      :missing_result_penalty,
      :name,
      :place_by,
      :points_for_place,
      :results_per_event,
      :source_event_keys,
      :specific_events,
      :team,
      :weekday_events,
      :year
    )
  end
end
