# frozen_string_literal: true

class AddOrderGateway < ActiveRecord::Migration
  def change
    begin
      add_column(:orders, :gateway, :string, null: true, default: nil)
    rescue StandardError
      nil
    end
    begin
      add_index(:orders, :gateway)
    rescue StandardError
      nil
    end

    Order.where(gateway: nil).purchased.update_all gateway: "elavon" if RacingAssociation.current.short_name == "NABRA"
  end
end
