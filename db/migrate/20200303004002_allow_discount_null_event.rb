# frozen_string_literal: true

class AllowDiscountNullEvent < ActiveRecord::Migration[5.2]
  def change
    change_column :discount_codes, :event_id, :integer, null: true, default: nil
  end
end
