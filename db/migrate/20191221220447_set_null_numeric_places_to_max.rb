class SetNullNumericPlacesToMax < ActiveRecord::Migration[5.2]
  def change
    Result.find_each do |result|
      result.set_numeric_place(result.place)
      result.save!
    end
    execute "update results set numeric_place=999999 where numeric_place is null"
  end
end
