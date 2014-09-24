class AddEventsJuniorPrice < ActiveRecord::Migration
  def change
    add_column :events, :junior_price, :decimal, precision: 10, scale: 2
  end
end
