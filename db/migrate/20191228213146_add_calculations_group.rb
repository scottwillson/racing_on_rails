class AddCalculationsGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :calculations, :group, :string, null: true, default: nil
    Calculations::V3::Calculation.where("`key` like ?", "%bar%").update_all(group: :bar)
  end
end
