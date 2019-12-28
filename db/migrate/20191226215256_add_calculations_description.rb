class AddCalculationsDescription < ActiveRecord::Migration[5.2]
  def change
    add_column :calculations, :description, :string, null: false, default: ""
  end
end
