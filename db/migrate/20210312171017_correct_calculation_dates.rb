class CorrectCalculationDates < ActiveRecord::Migration[6.1]
  def change
    Calculations::V3::Calculation.where(key: :ironman).map(&:event).each do |e|
      e.update_column(:date, Date.new(e.year))
      e.update_column(:end_date, Date.new(e.year, 12, 31))
    end

    Calculations::V3::Calculation.where("`key` like ?", "%bar%").map(&:event).compact.each do |e|
      e.update_column(:date, Date.new(e.year))
      e.update_column(:end_date, Date.new(e.year, 12, 31))
    end
  end
end
