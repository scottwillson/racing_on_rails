class AddEventFees < ActiveRecord::Migration
  def self.up
    add_column :events, :pre_event_fees, :float
    add_column :events, :post_event_fees, :float
    add_column :events, :flyer_ad_fee, :float
  end

  def self.down
  end
end
