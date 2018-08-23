class AddProductsStringValue < ActiveRecord::Migration[4.2]
  def change
    change_table(:products) do |t|
      t.column :string_value, :boolean, default: false
      t.column :string_value_placeholder, :string, default: nil
    end
  end
end
