class AddResultsPlaceNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :results, :place, false
  end
end
