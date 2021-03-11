class AddRaceRejectionDefaults < ActiveRecord::Migration[6.1]
  def change
    Race.where(rejected: nil).update_all(rejected: false)
    change_column :races, :rejected, :boolean, null: false, default: false
  end
end
