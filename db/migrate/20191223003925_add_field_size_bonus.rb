class AddFieldSizeBonus < ActiveRecord::Migration[5.2]
  def change
    add_column :calculations, :field_size_bonus, :boolean, default: false, null: false
  end
end
