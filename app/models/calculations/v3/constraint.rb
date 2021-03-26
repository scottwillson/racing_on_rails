# frozen_string_literal: true

class Calculations::V3::Constraint
  def matches?(request)
    year = request.params[:year] || Time.zone.today.year
    Calculations::V3::Calculation.exists? key: request.params[:key], year: year
  end
end
