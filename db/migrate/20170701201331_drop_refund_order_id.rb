class DropRefundOrderId < ActiveRecord::Migration
  def change
    remove_column(:refunds, :order_id, :integer) rescue true
  end
end
