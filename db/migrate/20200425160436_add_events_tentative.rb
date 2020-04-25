class AddEventsTentative < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :tentative, :boolean, default: false, null: false
    rename_column :events, :cancelled, :cancelled
  end
end
