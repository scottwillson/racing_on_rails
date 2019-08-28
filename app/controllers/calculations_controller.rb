# frozen_string_literal: true

class CalculationsController < ApplicationController
  def index
    @calculations = Calculations::V3::Calculation.all
  end
end
