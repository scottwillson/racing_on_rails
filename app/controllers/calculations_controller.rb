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
end
