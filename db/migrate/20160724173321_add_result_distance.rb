class AddResultDistance < ActiveRecord::Migration
  def change
    Race.where(distance: "").update_all distance: nil

    change_column :races, :distance, :decimal, precision: 10, scale: 2
    add_column :results, :distance, :decimal, precision: 10, scale: 2
  end
end
