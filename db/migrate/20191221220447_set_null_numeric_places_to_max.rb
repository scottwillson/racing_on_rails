class SetNullNumericPlacesToMax < ActiveRecord::Migration[5.2]
  def change
    execute "update results set numeric_place=999999 where numeric_place is null"
    Result.find_each do |result|
      result.set_numeric_place(result.place)
      if result.numeric_place_changed?
        result.update_column :numeric_place, result.numeric_place
      end
    end
  end
end
