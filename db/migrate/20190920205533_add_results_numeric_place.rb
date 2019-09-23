class AddResultsNumericPlace < ActiveRecord::Migration[5.2]
  def change
    change_table :results do |t|
      t.integer :numeric_place, default: 999_999
    end

    def up
      Result.find_each do |result|
        result.set_numeric_place(result.place)
        result.update_column :numeric_place, result.numeric_place
      end
    end
  end
end
