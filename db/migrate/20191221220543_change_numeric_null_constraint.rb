class ChangeNumericNullConstraint < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:results, :numeric_place, false)
  end
end
