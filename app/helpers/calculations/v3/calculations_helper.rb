# frozen_string_literal: true

module Calculations::V3::CalculationsHelper
  def link_to_calculation(calculation)
    return calculation.name unless calculation.event_id

    link_to calculation.name, friendly_calculation_path(calculation.key, calculation.year)
  end
end
