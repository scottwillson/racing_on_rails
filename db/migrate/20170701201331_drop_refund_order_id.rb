# frozen_string_literal: true

class DropRefundOrderId < ActiveRecord::Migration
  def change
    remove_column(:refunds, :order_id, :integer)
  rescue StandardError
    true
  end
end
