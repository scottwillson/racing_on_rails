class CreateCalculationsDisciplines < ActiveRecord::Migration[5.2]
  def change
    create_table :calculations_disciplines, force: true do |t|
      t.references :calculation
      t.references :discipline
      t.index %w[calculation_id discipline_id], name: "index_calc_disciplines_on_calculation_id_and_discipline_id", unique: true
      t.timestamps
    end
  end
end
