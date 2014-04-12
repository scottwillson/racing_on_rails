class AllowNullRentalNumbers < ActiveRecord::Migration
  def change
    change_column :racing_associations, :rental_numbers_end, :integer, :null => true, :default => nil
    change_column :racing_associations, :rental_numbers_start, :integer, :null => true, :default => nil
  end
end