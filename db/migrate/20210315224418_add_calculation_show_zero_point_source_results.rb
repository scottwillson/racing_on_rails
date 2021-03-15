class AddCalculationShowZeroPointSourceResults < ActiveRecord::Migration[6.1]
  def change
    change_table :calculations do |t|
      t.boolean :show_zero_point_source_results, default: true, null: false
    end

    Calculations::V3::Calculation.where(key: [:age_graded_bar, :overallbar]).update_all(
      show_zero_point_source_results: false
    )
  end
end
