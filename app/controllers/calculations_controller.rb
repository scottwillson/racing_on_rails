# frozen_string_literal: true

class CalculationsController < ApplicationController
  before_action :require_administrator, except: [:index, :show]

  def create
    @calculation = Calculations::V3::Calculation.new(calculation_params)
    if @calculation.save(calculation_params)
      flash[:notice] = "Created #{@calculation.name}"
      redirect_to edit_calculation_path(@calculation)
    else
      render :edit
    end
  end

  def edit
    @calculation = Calculations::V3::Calculation.find(params[:id])
    @calculation.calculations_events.new
  end

  def index
    @year = params[:year] || Time.zone.now.year
    @years = Calculations::V3::Calculation.pluck(:year).uniq
    @calculations = Calculations::V3::Calculation.where(year: @year)
  end

  def new
    @calculation = Calculations::V3::Calculation.new
    render :edit
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
      :event_notes,
      :group,
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
