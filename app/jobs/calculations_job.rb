# frozen_string_literal: true

class CalculationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Calculations::V3::Calculation.calculate!
  end
end
