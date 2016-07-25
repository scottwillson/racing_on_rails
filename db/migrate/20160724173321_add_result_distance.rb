class AddResultDistance < ActiveRecord::Migration
  def change
    add_column :results, :distance, :decimal, precision: 10, scale: 2
  end
end
