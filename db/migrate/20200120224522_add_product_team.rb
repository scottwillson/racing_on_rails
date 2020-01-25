class AddProductTeam < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :team, :boolean, default: false, null: false
  end
end
